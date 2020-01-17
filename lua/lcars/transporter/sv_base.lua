
-- List of active Transports.
LCARS.ActiveTransports = LCARS.ActiveTransports or {}

util.AddNetworkString("LCARS.Tranporter.BeamObject")

function LCARS:ApplyTranportEffectProperties(transportData, ent, mode)
    if mode == 1 then
        transportData.OldRenderMode = ent:GetRenderMode()
        ent:SetRenderMode(RENDERMODE_TRANSTEXTURE)

        transportData.OldCollisionGroup = ent:GetCollisionGroup()
        ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

        transportData.OldMoveType = ent:GetMoveType()
        ent:SetMoveType(MOVETYPE_NONE)

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            transportData.OldMotionEnabled = phys:IsMotionEnabled()
            phys:EnableMotion(false)
        end

        local trace = util.TraceLine({
            start = ent:GetPos(),
            endpos = ent:GetPos() - Vector(0, 0, 200),
            filter = ent
        })
        local distance = ent:GetPos():Distance(trace.HitPos)
        transportData.ZOffset = distance

        -- TODO: Fallback using Model Bounds?
        
        ent:DrawShadow(false)

        for _, child in pairs(ent:GetChildren()) do
            child.OldRenderMode = child:GetRenderMode()
            child:SetRenderMode(RENDERMODE_TRANSTEXTURE)

            child.OldColor = child:GetColor()
            child:SetColor(Color(255, 255, 255, 0))
        end
    elseif mode == 2 then
        ent:SetRenderMode(RENDERMODE_NONE)

        transportData.OldColor = ent:GetColor()
        ent:SetColor(Color(0, 0, 0, 0))
    elseif mode == 3 then
        ent:SetRenderMode(RENDERMODE_TRANSTEXTURE)

        ent:SetPos((transportData.TargetPos or ent:GetPos()) + Vector(0, 0, transportData.ZOffset))
        
    else
        ent:SetRenderMode(transportData.OldRenderMode)
        ent:SetCollisionGroup(transportData.OldCollisionGroup)
        ent:SetMoveType(transportData.OldMoveType)
        ent:SetColor(transportData.OldColor)
        
        -- Make sure Position is set properly.
        -- Looks strange but is needed. (Probably a bug with setting the Move Type back)
        ent:SetPos(ent:GetPos())
        
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(transportData.OldMotionEnabled)
            phys:Wake()
        end

        ent:DrawShadow(true)
        
        for _, child in pairs(ent:GetChildren()) do
            child:SetRenderMode(child.OldRenderMode)
            child.OldRenderMode = nil

            child:SetColor(child.OldColor)
            child.OldColor = nil
        end

        ent:Activate()
    end
end

function LCARS:BroadcastBeamEffect(ent, rematerialize)
    if not IsValid(ent) then return end
    
    local oldCollisionGroup = ent:GetCollisionGroup()
    ent:SetCollisionGroup(COLLISION_GROUP_NONE)

    local players = {}
    for _, ply in pairs(player.GetHumans()) do
        if ply:VisibleVec(ent:GetPos()) then
            table.insert(players, ply)
        end
    end

    ent:SetCollisionGroup(oldCollisionGroup)

    if rematerialize then
        ent:EmitSound("voyager.beam_down")
    else
        ent:EmitSound("voyager.beam_up")
    end

    timer.Simple(0.5, function()
        net.Start("LCARS.Tranporter.BeamObject")
            net.WriteEntity(ent)
            net.WriteBool(rematerialize)
        net.Send(players)
    end)
end

// TODO: Relative Stuff + Parented Objects.
// TODO: Model Bounds for Offset to Ground?
function LCARS:BeamObject(ent, targetPos, sourcePad, targetPad)
    local transportData = {
        Object = ent,
        TargetPos = targetPos or ent:GetPos(),
        StateTime = CurTime(),
        State = 0,
        SourcePad = sourcePad,
        TargetPad = targetPad,
    }

    for _, transportData in pairs(self.ActiveTransports) do
        if transportData.Object == ent then return end
    end

    if IsValid(sourcePad) then
        sourcePad:SetSkin(1)
    end
    
    self:ApplyTranportEffectProperties(transportData, ent, 1)
    self:BroadcastBeamEffect(ent, false)
    
    table.insert(self.ActiveTransports, transportData)
end

hook.Add("Think", "LCARS.Tranporter.Cycle", function()
    local toBeRemoved = {}
    for _, transportData in pairs(LCARS.ActiveTransports) do
        local curTime = CurTime()

        local stateTime = transportData.StateTime
        local state = transportData.State
        local ent = transportData.Object
        if IsValid(ent) then
            if state == 0 and (stateTime + 3) < curTime then
                -- Object is now dematerialized and moved to the buffer!
                LCARS:ApplyTranportEffectProperties(transportData, ent, 2)

                -- TODO: Replace with Buffer
                --ent:SetPos(transportData.TargetPos or ent:GetPos())
                
                transportData.StateTime = curTime
                transportData.State = 1
                
                if IsValid(transportData.SourcePad) then
                    transportData.SourcePad:SetSkin(0)
                end
            elseif state == 1 and (stateTime + 4) < curTime then
                -- Object will now be removed from the buffer.
                LCARS:ApplyTranportEffectProperties(transportData, ent, 3)
                
                LCARS:BroadcastBeamEffect(ent, true)
                
                transportData.StateTime = curTime
                transportData.State = 2

                if IsValid(transportData.TargetPad) then
                    transportData.TargetPad:SetSkin(1)
                end
            elseif state == 2 and (stateTime + 3) < curTime then
                -- Object is now visible again.
                LCARS:ApplyTranportEffectProperties(transportData, ent, 4)
                

                if IsValid(transportData.TargetPad) then
                    transportData.TargetPad:SetSkin(0)
                end

                table.insert(toBeRemoved, transportData)
            end
        else
            table.insert(toBeRemoved, transportData)
        end

        
    end

    for _, transportData in pairs(toBeRemoved) do
        table.RemoveByValue(LCARS.ActiveTransports, transportData)
    end
end)
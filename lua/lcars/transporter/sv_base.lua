
-- List of active Transports.
LCARS.ActiveTransports = LCARS.ActiveTransports or {}

util.AddNetworkString("LCARS.Tranporter.BeamObject")
util.AddNetworkString("LCARS.Tranporter.BeamPlayer")

local setupBuffer = function()
    LCARS.BeamBuffer = ents.FindByName("beamBuffer")[1]
end
hook.Add("InitPostEntity", "LCARS.BufferInitPostEntity", setupBuffer)
hook.Add("PostCleanupMap", "LCARS.BufferPostCleanupMap", setupBuffer)


function LCARS:ApplyTranportEffectProperties(transportData, ent)
    local mode = transportData.State

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

        if ent:IsPlayer() then
            ent:Lock()
        end

        local lowerBounds, higherBounds = ent:GetCollisionBounds()
        transportData.ZOffset = -lowerBounds.Z + 2 -- Offset to prevent stucking in floor

        ent:DrawShadow(false)

        for _, child in pairs(ent:GetChildren()) do
            child.OldRenderMode = child:GetRenderMode()
            child:SetRenderMode(RENDERMODE_TRANSTEXTURE)

            child.OldColor = child:GetColor()
            child:SetColor(Color(255, 255, 255, 0))
        end

        if ent:IsPlayer() then
            net.Start("LCARS.Tranporter.BeamPlayer")
                net.WriteBool(true)
            net.Send(ent)
        end
    elseif mode == 2 then
        ent:SetRenderMode(RENDERMODE_NONE)

        transportData.OldColor = ent:GetColor()
        ent:SetColor(Color(0, 0, 0, 0))
    elseif mode == 3 then
        ent:SetRenderMode(RENDERMODE_TRANSTEXTURE)
        
        if transportData.OldColor ~= nil then
            ent:SetColor(transportData.OldColor)
        end

        ent:SetPos((transportData.TargetPos or ent:GetPos()) + Vector(0, 0, transportData.ZOffset))
        
        if ent:IsPlayer() then
            net.Start("LCARS.Tranporter.BeamPlayer")
                net.WriteBool(false)
            net.Send(ent)
        end
    else
        if transportData.OldRenderMode ~= nil then
            ent:SetRenderMode(transportData.OldRenderMode)
        end

        if transportData.OldCollisionGroup ~= nil then
            ent:SetCollisionGroup(transportData.OldCollisionGroup)
        end

        if transportData.OldMoveType ~= nil then
            ent:SetMoveType(transportData.OldMoveType)
        end
        
        -- Make sure Position is set properly.
        -- Looks strange but is needed. (Probably a bug with setting the Move Type back)
        ent:SetPos(ent:GetPos())
        
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            if transportData.OldMotionEnabled ~= nil then
                phys:EnableMotion(transportData.OldMotionEnabled)
            end
            
            phys:Wake()
        end

        if ent:IsPlayer() then
            ent:UnLock()
        end

        ent:DrawShadow(true)
        
        for _, child in pairs(ent:GetChildren()) do
            if child.OldRenderMode ~= nil then
                child:SetRenderMode(child.OldRenderMode)
            end
            
            child.OldRenderMode = nil

            child:SetColor(child.OldColor)
            child.OldColor = nil
        end

        ent:Activate()
    end
end

function LCARS:BroadcastBeamEffect(ent, rematerialize, replicator)
    if not IsValid(ent) then return end
    
    local oldCollisionGroup = ent:GetCollisionGroup()
    ent:SetCollisionGroup(COLLISION_GROUP_NONE)

    local lowerBounds, higherBounds = ent:GetCollisionBounds()
    local midPos = ent:GetPos() + (higherBounds / 2) + (lowerBounds / 2)
    --debugoverlay.Cross(midPos, 32, 10, true)

    local players = {}
    for _, ply in pairs(player.GetHumans()) do
        if ply:VisibleVec(midPos) then
            table.insert(players, ply)
        end
    end

    ent:SetCollisionGroup(oldCollisionGroup)

    if replicator then
        ent:EmitSound("voyager.tng_replicator")
    else
        if rematerialize then
            ent:EmitSound("voyager.beam_down")
        else
            ent:EmitSound("voyager.beam_up")
        end
    end

    timer.Simple(0.5, function()
        net.Start("LCARS.Tranporter.BeamObject")
            net.WriteEntity(ent)
            net.WriteBool(rematerialize)
            net.WriteBool(replicator or false)
        net.Send(players)
    end)
end

function LCARS:BeamObject(ent, targetPos, sourcePad, targetPad, toBuffer)
    local transportData = {
        Object = ent,
        TargetPos = targetPos or ent:GetPos(),
        StateTime = CurTime(),
        State = 1,
        SourcePad = sourcePad,
        TargetPad = targetPad,
        ToBuffer = toBuffer
    }

    for _, transportData in pairs(self.ActiveTransports) do
        if transportData.Object == ent then return end
    end

    if IsValid(sourcePad) then
        sourcePad:SetSkin(1)
    end
    if ent.BufferData then
        transportData = ent.BufferData
        ent.BufferData = nil
        
        transportData.TargetPos = targetPos or ent:GetPos()
        transportData.TargetPad = targetPad
        transportData.ToBuffer = false
    else
        self:ApplyTranportEffectProperties(transportData, ent)
        self:BroadcastBeamEffect(ent, false)
    end
    
    table.insert(self.ActiveTransports, transportData)
end

function LCARS:ReplicateObject(ent, rematerialize)
    local transportData = {
        Object = ent,
        TargetPos = ent:GetPos(),
        StateTime = CurTime(),
        ToBuffer = true,
        Replicator = true
    }

    for _, transportData in pairs(self.ActiveTransports) do
        if transportData.Object == ent then return end
    end

    if rematerialize then
        transportData.State = 2
        transportData.StateTime = CurTime() - 3
    else
        transportData.State = 1
    end
    
    self:ApplyTranportEffectProperties(transportData, ent)

    if not rematerialize then
        self:BroadcastBeamEffect(ent, false, true)
    end
    
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
            if state == 1 and (stateTime + 3) < curTime then
                transportData.State = 2

                -- Object is now dematerialized and moved to the buffer!
                LCARS:ApplyTranportEffectProperties(transportData, ent)

                -- TODO: Replace with Buffer
                ent:SetPos(LCARS.BeamBuffer:GetPos())
                
                transportData.StateTime = curTime
                
                if IsValid(transportData.SourcePad) then
                    transportData.SourcePad:SetSkin(0)
                end

                if transportData.Replicator then
                    table.insert(toBeRemoved, transportData)
                end

                if transportData.ToBuffer then
                    transportData.Object.BufferData = transportData

                    table.insert(toBeRemoved, transportData)
                end
            elseif state == 2 and (stateTime + 4) < curTime then
                transportData.State = 3

                -- Object will now be removed from the buffer.
                LCARS:ApplyTranportEffectProperties(transportData, ent)
                
                LCARS:BroadcastBeamEffect(ent, true, transportData.Replicator)
                
                transportData.StateTime = curTime

                if IsValid(transportData.TargetPad) then
                    transportData.TargetPad:SetSkin(1)
                end
            elseif state == 3 and (stateTime + 3) < curTime then
                transportData.State = 4

                -- Object is now visible again.
                LCARS:ApplyTranportEffectProperties(transportData, ent)
                
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
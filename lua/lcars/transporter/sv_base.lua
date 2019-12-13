
-- List of active Transports.
LCARS.ActiveTransports = LCARS.ActiveTransports or {}

util.AddNetworkString("LCARS.Tranporter.BeamObject")

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
    
    ent:DrawShadow(false)

    self:BroadcastBeamEffect(ent, false)
    
    table.insert(self.ActiveTransports, transportData)
end

function LCARS:GetTransporterObjects(window, listWindow)
    local objects = {}

    local sourceMode = window.Selected
        
    for _, button in pairs(listWindow.Buttons) do
        if button.Selected then
            local object = nil

            if sourceMode == 1 then
                local pad = button.Data
                local pos = button.Data:GetPos()
                local attachmentId = pad:LookupAttachment("teleportPoint")
                if attachmentId > 0 then
                    local angPos = pad:GetAttachment(attachmentId)

                    pos = angPos.Pos
                end

                object = {
                    Objects = {},
                    Pad = pad,
                    Pos = pos,
                    SourceCount = 1,
                    TargetCount = 1,
                }

                local entities = ents.FindInSphere(pos, 35)
                for _, ent in pairs(entities) do
                    local name = ent:GetName()
                    if not string.StartWith(name, "TRPad") then
                        table.insert(object.Objects, ent)
                    end
                end
            elseif sourceMode == 2 then
                print(button.Name, button.Data)
                object = {
                    Objects = {button.Data},
                    Pos = button.Data:GetPos(),
                    SourceCount = 1,
                    TargetCount = -1,
                }
            elseif sourceMode == 3 then
                -- TODO: Add Markers
            end

            table.insert(objects, object)
        end
    end

    return objects
end

function LCARS:ActivateTransporter(panelData)
    local Sources = self:GetTransporterObjects(panelData.Windows[1], panelData.Windows[3])
    local Targets = self:GetTransporterObjects(panelData.Windows[2], panelData.Windows[4])

    print("---")
    PrintTable(Sources)
    print("---")
    PrintTable(Targets)

    for _, source in pairs(Sources) do
        for _, sourceObject in pairs(source.Objects) do
            for _, target in pairs(Targets) do
                target.Count = target.Count or 0

                if target.TargetCount == -1 or target.Count < target.TargetCount then
                    self:BeamObject(sourceObject, target.Pos, source.Pad, target.Pad)

                    target.Count = target.Count + 1
                    break
                end
            end
        end
    end

    return true
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

                ent:SetRenderMode(RENDERMODE_NONE)

                -- TODO: Replace with Buffer
                --ent:SetPos(transportData.TargetPos or ent:GetPos())
                
                transportData.StateTime = curTime
                transportData.State = 1
                
                if IsValid(transportData.SourcePad) then
                    transportData.SourcePad:SetSkin(0)
                end
            elseif state == 1 and (stateTime + 4) < curTime then
                -- Object will now be removed from the buffer.

                ent:SetRenderMode(RENDERMODE_TRANSTEXTURE)
                
                ent:SetPos(transportData.TargetPos or ent:GetPos())
                
                LCARS:BroadcastBeamEffect(ent, true)
                
                transportData.StateTime = curTime
                transportData.State = 2

                if IsValid(transportData.TargetPad) then
                    transportData.TargetPad:SetSkin(1)
                end
            elseif state == 2 and (stateTime + 3) < curTime then
                -- Object is now visible again.

                if IsValid(transportData.TargetPad) then
                    transportData.TargetPad:SetSkin(0)
                end

                ent:SetRenderMode(transportData.OldRenderMode)
                ent:SetCollisionGroup(transportData.OldCollisionGroup)
                ent:SetMoveType(transportData.OldMoveType)
                    
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    phys:EnableMotion(transportData.OldMotionEnabled)
                    phys:Wake()
                end
            
                ent:DrawShadow(true)

                ent:Activate()
            
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
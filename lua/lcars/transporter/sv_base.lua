
-- List of active Transports.
LCARS.ActiveTransports = LCARS.ActiveTransports or {}

util.AddNetworkString("LCARS.Tranporter.BeamObject")

function LCARS:BroadcastBeamEffect(ent, rematerialize)
    if not IsValid(ent) then return end
    
    local oldCollisionGroup = ent:GetCollisionGroup()
    ent:SetCollisionGroup(COLLISION_GROUP_NONE)

    local players = {}
    for _, ply in pairs(player.GetHumans()) do
        --local trace = util.TraceLine({
        --    start = ply:GetShootPos(),
        --    endpos = ent:GetPos(),
        --    filter = ply,
        --    mask = MASK_NPCWORLDSTATIC,
        --})

        --if not trace.Hit then
        --    table.insert(players, ply)
        --end

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

function LCARS:BeamObject(ent, targetPos)
    local transportData = {
        Object = ent,
        TargetPos = targetPos,
        StateTime = CurTime(),
        State = 0,
    }

    for _, transportData in pairs(self.ActiveTransports) do
        if transportData.Object == ent then return end
    end
    
    transportData.OldRenderMode = ent:GetRenderMode()
    ent:SetRenderMode(RENDERMODE_TRANSTEXTURE)

    transportData.OldCollisionGroup = ent:GetCollisionGroup()
    ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    local phys = ent:GetPhysicsObject()
    if phys then
        transportData.OldMotionEnabled = phys:IsMotionEnabled()
        phys:EnableMotion(false)
    end
    
    ent:DrawShadow(false)

    self:BroadcastBeamEffect(ent, false)
    
    table.insert(self.ActiveTransports, transportData)
end

function LCARS:OpenTransporterMenu()
    self:OpenMenuInternal(TRIGGER_PLAYER, CALLER, function(ply, panel_brush, panel, screenPos, screenAngle)
        local panelData = {
            Type = "Transporter",
            Pos = screenPos + Vector(0, 0, 5),
            Angles = screenAngle,
            Width = 2000,
            Height = 200,
            Windows = {
                [1] = {
                    Pos = Vector(),
                    Type = "transport_slider",
                    Width = 200,
                    Height = 200,
                    Buttons = {}
                },
                [2] = {
                    Pos = Vector(-300, 0, 0),
                    Type = "button_list",
                    Width = 200,
                    Height = 200,
                    Buttons = {
                        {Name = "Test1", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test2", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test3", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test4", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test5", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test6", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test7", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test8", RandomS = "01", RandomL = "14-3123"},
                    }
                },
                [3] = {
                    Pos = Vector(300, 0, 0),
                    Type = "button_list",
                    Width = 200,
                    Height = 200,
                    Buttons = {
                        {Name = "Test1", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test2", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test3", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test4", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test5", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test6", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test7", RandomS = "01", RandomL = "14-3123"},
                        {Name = "Test8", RandomS = "01", RandomL = "14-3123"},
                    }
                },
            },
        }

        PrintTable(panelData)

        self:SendPanel(panel, panelData)
    end)
end

-- Call FireUser on all Presses
hook.Add("LCARS.PressedCustom", "LCARS.Transporter.Pressed", function(ply, panelData, panel, panelBrush, windowId, buttonId)
    if not panelData.Type == "Transporter" then return end

    print(ply, panelData, panel, panelBrush, windowId, buttonId)
end)

hook.Add("Think", "LCARS.Tranporter.Cycle", function()
    local toBeRemoved = {}
    for _, transportData in pairs(LCARS.ActiveTransports) do
        local curTime = CurTime()

        local stateTime = transportData.StateTime
        local state = transportData.State
        local ent = transportData.Object
        if IsValid(ent) then
            if state == 0 and (stateTime + 3) < curTime then
                ent:SetRenderMode(RENDERMODE_NONE)
                
                transportData.StateTime = curTime
                transportData.State = 1
            elseif state == 1 and (stateTime + 4) < curTime then
                ent:SetRenderMode(RENDERMODE_TRANSTEXTURE)
                
                LCARS:BroadcastBeamEffect(ent, true)
                
                transportData.StateTime = curTime
                transportData.State = 2
            elseif state == 2 and (stateTime + 3) < curTime then
                ent:SetRenderMode(transportData.OldRenderMode)
                ent:SetCollisionGroup(transportData.OldCollisionGroup)
                    
                local phys = ent:GetPhysicsObject()
                if phys then
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
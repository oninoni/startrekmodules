
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

    local phys = ent:GetPhysicsObject()
    if phys then
        transportData.OldMotionEnabled = phys:IsMotionEnabled()
        phys:EnableMotion(false)
    end
    
    ent:DrawShadow(false)

    self:BroadcastBeamEffect(ent, false)
    
    table.insert(self.ActiveTransports, transportData)
end

function LCARS:ReaplaceModeButtons(windowId, listWindow, objects)
    listWindow.Buttons = {}

    local j = 1
    for _, object in pairs(objects) do
        local color = LCARS.ColorBlue
        if (windowId + j)%2 == 0 then
            color = LCARS.ColorLightBlue
        end

        local button = LCARS:CreateButton(object.Name, color)
        button.Data = object.Data

        if isstring(object.Type) then
            button.Type = object.Type
            button.X = object.X
            button.Y = object.Y
            button.Radius = object.Radius
        end
        
        button.Selected = false
        button.DeselectedColor = color

        table.insert(listWindow.Buttons, button)

        j = j + 1
    end
end

function LCARS:GeneratePadButtons(listWindow, objects, padNumber)
    listWindow.Type = "transport_pad"
    
    local radius = listWindow.Height / 8
    local offset = radius * 2.5
    local outerX = 0.5 * offset
    local outerY = 0.866 * offset

    for _, ent in pairs(ents.GetAll()) do
        local name = ent:GetName()
        if string.StartWith(name, "TRPad") then
            local values = string.Split(string.sub(name, 6), "_")
            local k = tonumber(values[1])
            local n = tonumber(values[2])
            
            if n ~= padNumber then continue end
            
            local object = {
                Name = ent:GetName(),
                Data = ent,
                Radius = radius,
            }

            if k == 7 then
                object.X = 0
                object.Y = 0
                object.Type = "Round"
            else
                if k == 3 or k == 4 then
                    if k == 3 then
                        object.X = -offset
                    else
                        object.X =  offset
                    end

                    object.Y = 0
                else
                    if k == 1 or k == 2 then
                        object.Y = outerY
                    elseif k == 5 or k == 6 then
                        object.Y = -outerY
                    end

                    if k == 1 or k == 5 then
                        object.X = -outerX
                    elseif k == 2 or k == 6 then
                        object.X = outerX
                    end
                end

                object.Type = "Hex"
            end
            
            objects[k] = object
        end
    end

    return objects
end

function LCARS:ReplaceButtons(windowId, listWindow, mode)
    local objects = {}

    if mode == 1 then
        self:GeneratePadButtons(listWindow, objects, 1)
        -- TODO: Replace 1 with Linking of Pad and Console
        
    elseif mode == 2 then
        listWindow.Type = "button_list"
        -- TODO: Maybe add NPC's?
        for _, ply in pairs(player.GetHumans()) do
            local object = {
                Name = ply:GetName(),
                Data = ply,
            }

            table.insert(objects, object)
        end
    elseif mode == 3 then
        listWindow.Type = "button_list"
        -- TODO: Add Markers
    end

    return self:ReaplaceModeButtons(windowId, listWindow, objects)
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

local targetNames = {
    "Transporter Pad",
    "Crew",
    "Marker",
}
function LCARS:OpenTransporterMenu()
    local panel = self:OpenMenuInternal(TRIGGER_PLAYER, CALLER, function(ply, panel_brush, panel, screenPos, screenAngle)
        local panelData = {
            Type = "Transporter",
            Pos = screenPos + Vector(0, 0, 10),
            Width = 2000,
            Height = 300,
            Windows = {
                [1] = {
                    Pos = screenPos + Vector(14, 0, 10),
                    Angles = screenAngle - Angle(20, -20, 0),
                    Type = "button_list",
                    Width = 350,
                    Height = 300,
                    Buttons = {}
                },
                [2] = {
                    Pos = screenPos + Vector(-14, 0, 10),
                    Angles = screenAngle - Angle(20, 20, 0),
                    Type = "button_list",
                    Width = 350,
                    Height = 300,
                    Buttons = {}
                },
                [3] = {
                    Pos = screenPos + Vector(32, 12, 10),
                    Angles = screenAngle - Angle(20, -45, 0),
                    Type = "button_list",
                    Width = 600,
                    Height = 300,
                    Buttons = {}
                },
                [4] = {
                    Pos = screenPos + Vector(-32, 12, 10),
                    Angles = screenAngle - Angle(20, 45, 0),
                    Type = "button_list",
                    Width = 600,
                    Height = 300,
                    Buttons = {}
                },
            },
        }

        for i=1,2,1 do
            for j=1,3,1 do
                local color = LCARS.ColorBlue
                if (i + j)%2 == 0 then
                    color = LCARS.ColorLightBlue
                end

                local button = LCARS:CreateButton(targetNames[j], color)
                button.DeselectedColor = color

                table.insert(panelData.Windows[i].Buttons, button)
            end
        end

        panelData.Windows[1].Selected = 2
        panelData.Windows[1].Buttons[2].Color = LCARS.ColorYellow
        panelData.Windows[2].Selected = 1
        panelData.Windows[2].Buttons[1].Color = LCARS.ColorYellow

        panelData.Windows[1].Buttons[5] = LCARS:CreateButton("Narrow Beam", LCARS.ColorOrange)
        panelData.Windows[1].Buttons[5].Selected = false
        panelData.Windows[2].Buttons[5] = LCARS:CreateButton("Direct Transport", LCARS.ColorOrange)
        panelData.Windows[2].Buttons[5].Selected = false

        panelData.Windows[1].Buttons[6] = LCARS:CreateButton("Swap Sides", LCARS.ColorOrange)
        panelData.Windows[1].Buttons[6].Selected = false
        panelData.Windows[2].Buttons[6] = LCARS:CreateButton("Disable Console", LCARS.ColorRed)
        panelData.Windows[2].Buttons[6].Selected = false

        for i=1,2,1 do
            LCARS:ReplaceButtons(i, panelData.Windows[2 + i], panelData.Windows[i].Selected)
        end


        self:SendPanel(panel, panelData)
    end)
    
    if IsValid(panel) then
        local panelData = self.ActivePanels[panel]
        if not istable(panelData) then return end
        
        local success = LCARS:ActivateTransporter(panelData)
        if success then
            local panel_brush = CALLER
            panel_brush:Fire("FireUser1")

            timer.Simple(4, function()
                panel_brush:Fire("FireUser2")
            end)
        end
    end
end

-- Call FireUser on all Presses
hook.Add("LCARS.PressedCustom", "LCARS.Transporter.Pressed", function(ply, panelData, panel, panelBrush, windowId, buttonId)
    if not panelData.Type == "Transporter" then return end
    
    local window = panelData.Windows[windowId]
    if not istable(window) then return end

    local button = window.Buttons[buttonId]
    if not istable(button) then return end

    if windowId == 1 or windowId == 2 then
        if buttonId >= 1 and buttonId <= 3 then
            local listWindow = panelData.Windows[2 + windowId]

            for i=1,3,1 do
                window.Buttons[i].Color = window.Buttons[i].DeselectedColor
            end

            window.Selected = buttonId
            window.Buttons[window.Selected].Color = LCARS.ColorYellow

            LCARS:ReplaceButtons(windowId, listWindow, window.Selected)

            LCARS:UpdateWindow(panel, windowId, window)
            LCARS:UpdateWindow(panel, windowId + 2, listWindow)
        elseif buttonId == 5 then
            button.Selected = not button.Selected
            
            if button.Selected then
                button.Color = LCARS.ColorRed
                if windowId == 1 then
                    button.Name = "Wide Beam"
                else
                    button.Name = "Buffer Transport"
                end
            else
                button.Color = LCARS.ColorOrange
                if windowId == 1 then
                    button.Name = "Narrow Beam"
                else
                    button.Name = "Direct Transport"
                end
            end

            LCARS:UpdateWindow(panel, windowId, window)
        end
        

        
    elseif windowId == 3 or windowId == 4 then
        button.Selected = not button.Selected

        if button.Selected then
            button.Color = LCARS.ColorYellow
        else
            button.Color = button.DeselectedColor
        end

        LCARS:UpdateWindow(panel, windowId, window)
    end
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

                -- TODO: Replace with Buffer
                --ent:SetPos(transportData.TargetPos or ent:GetPos())
                
                transportData.StateTime = curTime
                transportData.State = 1
                
                if IsValid(transportData.SourcePad) then
                    transportData.SourcePad:SetSkin(0)
                end
            elseif state == 1 and (stateTime + 4) < curTime then
                ent:SetRenderMode(RENDERMODE_TRANSTEXTURE)
                
                ent:SetPos(transportData.TargetPos or ent:GetPos())
                
                LCARS:BroadcastBeamEffect(ent, true)
                
                transportData.StateTime = curTime
                transportData.State = 2

                if IsValid(transportData.TargetPad) then
                    transportData.TargetPad:SetSkin(1)
                end
            elseif state == 2 and (stateTime + 3) < curTime then
                if IsValid(transportData.TargetPad) then
                    transportData.TargetPad:SetSkin(0)
                end

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

local targetNames = {
    "Transporter Pad",
    "Lifeforms",
    "Locations",
    {"Buffer", "Other Pads"},
}

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
    elseif mode == 4 then
        if windowId == 1 then
            listWindow.Type = "button_list"
            -- TODO: Add Buffer
        elseif windowId == 2 then
            listWindow.Type = "button_list"
            -- TODO: Other Pads
        end
    end

    return self:ReaplaceModeButtons(windowId, listWindow, objects)
end

function LCARS:GetTransporterObjects(window, listWindow)
    local objects = {}
    local objectEntities = {}

    local sourceMode = window.Selected
    
    for _, button in pairs(listWindow.Buttons) do
        if button.Selected then
            local object = nil

            if sourceMode == 1 then
                local pad = button.Data
                local pos = pad:GetPos()
                local attachmentId = pad:LookupAttachment("teleportPoint")
                if attachmentId > 0 then
                    local angPos = pad:GetAttachment(attachmentId)

                    pos = angPos.Pos
                end

                object = {
                    Objects = {},
                    Pad = pad,
                    Pos = pos,
                    TargetCount = 1, -- Only 1 Object per Pad
                }

                local  lowerBounds = pos - Vector(25, 25, 0)
                local higherBounds = pos + Vector(25, 25, 120)
                --debugoverlay.Box(pos, -Vector(25, 25, 0), Vector(25, 25, 120), 10, Color(255, 255, 255, 63))

                local entities = ents.FindInBox(lowerBounds, higherBounds)
                for _, ent in pairs(entities) do
                    local name = ent:GetName()
                    if not string.StartWith(name, "TRPad") then
                        table.insert(object.Objects, ent)
                    end
                end
            elseif sourceMode == 2 then
                local targetEnt = button.Data
                local pos = targetEnt:GetPos()
                
                object = {
                    Objects = {targetEnt},
                    Pos = pos,
                    TargetCount = -1, -- Infinite Objects on beaming to player.
                }

                if window.Buttons[#targetNames + 2].Selected then
                    local  lowerBounds = pos - Vector(60, 60, 0)
                    local higherBounds = pos + Vector(60, 60, 120)
                    debugoverlay.Box(pos, -Vector(60, 60, 0), Vector(60, 60, 120), 10, Color(255, 255, 255, 63))

                    local entities = ents.FindInBox(lowerBounds, higherBounds)
                    for _, ent in pairs(entities) do
                        if ent:MapCreationID() ~= -1 then continue end

                        local parent = ent:GetParent()
                        if not IsValid(parent) then
                            local phys = ent:GetPhysicsObject()
                            if IsValid(phys) and phys:IsMotionEnabled() and ent ~= targetEnt then
                                table.insert(object.Objects, ent)
                            end
                        end
                    end
                end
            elseif sourceMode == 3 then
                -- TODO: Add Markers
            elseif sourceMode == 4 then
                -- TODO: Add Buffer/External Pads
            end

            table.insert(objects, object)
            for _, ent in pairs(object.Objects) do
                table.insert(objectEntities, ent)
            end
        end
    end

    -- Detect any Parenting
    local childEntities = {}
    for _, ent in pairs(objectEntities) do
        local parent = ent:GetParent()
        if parent and IsValid(parent) then
            table.insert(childEntities, ent)
        end
    end

    -- Only Transport the Parent entities (If they are indeed in the selection)
    for _, ent in pairs(childEntities) do
        for _, object in pairs(objects) do
            if table.HasValue(object.Objects, ent) then
                table.RemoveByValue(object.Objects, ent)
            end

            -- TODO: Check for the Parent and add some effect functionality for child Entities
        end
    end

    return objects
end

function LCARS:ActivateTransporter(panelData)
    local Sources = self:GetTransporterObjects(panelData.Windows[1], panelData.Windows[3])
    local Targets = self:GetTransporterObjects(panelData.Windows[2], panelData.Windows[4])

    for _, source in pairs(Sources or {}) do
        for _, sourceObject in pairs(source.Objects or {}) do
            for _, target in pairs(Targets or {}) do
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
function LCARS:OpenTransporterMenu()
    local panel = self:OpenMenuInternal(TRIGGER_PLAYER, CALLER, function(ply, panel_brush, panel, screenPos, screenAngle)
        local panelData = {
            Type = "Transporter",
            Pos = screenPos + Vector(0, 0, 10),
            Windows = {
                [1] = {
                    Pos = screenPos + Vector(22, -3, 12),
                    Angles = screenAngle - Angle(30, -25, 0),
                    Type = "button_list",
                    Width = 350,
                    Height = 300,
                    Buttons = {}
                },
                [2] = {
                    Pos = screenPos + Vector(-22, -3, 12),
                    Angles = screenAngle - Angle(30, 25, 0),
                    Type = "button_list",
                    Width = 350,
                    Height = 300,
                    Buttons = {}
                },
                [3] = {
                    Pos = screenPos + Vector(36, 13, 13),
                    Angles = screenAngle - Angle(30, -65, 0),
                    Type = "button_list",
                    Width = 500,
                    Height = 500,
                    Buttons = {}
                },
                [4] = {
                    Pos = screenPos + Vector(-36, 13, 13),
                    Angles = screenAngle - Angle(30, 65, 0),
                    Type = "button_list",
                    Width = 500,
                    Height = 500,
                    Buttons = {}
                },
            },
        }

        for i=1,2,1 do
            for j=1,#targetNames,1 do
                local color = LCARS.ColorBlue
                if (i + j)%2 == 0 then
                    color = LCARS.ColorLightBlue
                end

                local targetName = targetNames[j]
                if istable(targetName) then
                    targetName = targetName[i]
                end
                
                local button = LCARS:CreateButton(targetName, color)
                button.DeselectedColor = color

                table.insert(panelData.Windows[i].Buttons, button)
            end
        end

        panelData.Windows[1].Selected = 2
        panelData.Windows[1].Buttons[2].Color = LCARS.ColorYellow
        panelData.Windows[2].Selected = 1
        panelData.Windows[2].Buttons[1].Color = LCARS.ColorYellow

        panelData.Windows[1].Buttons[6] = LCARS:CreateButton("Narrow Beam", LCARS.ColorOrange)
        panelData.Windows[1].Buttons[6].Selected = false
        panelData.Windows[2].Buttons[6] = LCARS:CreateButton("Direct Transport", LCARS.ColorOrange)
        panelData.Windows[2].Buttons[6].Selected = false

        panelData.Windows[1].Buttons[7] = LCARS:CreateButton("Swap Sides", LCARS.ColorOrange)
        panelData.Windows[1].Buttons[7].Selected = false
        panelData.Windows[2].Buttons[7] = LCARS:CreateButton("Disable Console", LCARS.ColorRed)
        panelData.Windows[2].Buttons[7].Selected = false

        for i=1,2,1 do
            LCARS:ReplaceButtons(i, panelData.Windows[2 + i], panelData.Windows[i].Selected)
        end

        self:SendPanel(panel, panelData)
    end)

    if IsValid(panel) and not panel.ActiveTransporter then
        local panelData = self.ActivePanels[panel]
        if not istable(panelData) then return end
        
        local success = LCARS:ActivateTransporter(panelData)
        if success then
            panel.ActiveTransporter = true

            local panel_brush = CALLER
            panel_brush:Fire("FireUser1")

            timer.Simple(7, function()
                panel_brush:Fire("FireUser2")
                timer.Simple(3, function()
                    panel.ActiveTransporter = false
                end)
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
        if buttonId >= 1 and buttonId <= #targetNames then
            local listWindow = panelData.Windows[2 + windowId]

            for i=1,#targetNames,1 do
                window.Buttons[i].Color = window.Buttons[i].DeselectedColor
            end

            window.Selected = buttonId
            window.Buttons[window.Selected].Color = LCARS.ColorYellow

            LCARS:ReplaceButtons(windowId, listWindow, window.Selected)

            LCARS:UpdateWindow(panel, windowId, window)
            LCARS:UpdateWindow(panel, windowId + 2, listWindow)
        elseif buttonId == #targetNames + 2 then
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
        elseif buttonId == #targetNames + 3 then
            if windowId == 1 then
                local leftWindow = panelData.Windows[1]
                local rightWindow = panelData.Windows[2]
                
                if leftWindow.Selected > 3 or rightWindow.Selected > 3 then
                    -- TODO: Swap Error
                    return
                end

                for i=1,#targetNames,1 do
                    leftWindow.Buttons[i].Color = leftWindow.Buttons[i].DeselectedColor
                    rightWindow.Buttons[i].Color = rightWindow.Buttons[i].DeselectedColor
                end

                local selected = leftWindow.Selected
                leftWindow.Selected = rightWindow.Selected
                rightWindow.Selected = selected
                
                leftWindow.Buttons[leftWindow.Selected].Color = LCARS.ColorYellow
                rightWindow.Buttons[rightWindow.Selected].Color = LCARS.ColorYellow

                local leftListWindow = panelData.Windows[3]
                local rightListWindow = panelData.Windows[4]

                local leftSelected = {}
                for i, button in pairs(leftListWindow.Buttons) do
                    if button.Selected then 
                        table.insert(leftSelected, button.Data)
                    end
                end
                
                local rightSelected = {}
                for i, button in pairs(rightListWindow.Buttons) do
                    if button.Selected then 
                        table.insert(rightSelected, button.Data)
                    end
                end

                LCARS:ReplaceButtons(1, leftListWindow, leftWindow.Selected)
                LCARS:ReplaceButtons(2, rightListWindow, rightWindow.Selected)

                for _, selectedData in pairs(leftSelected) do
                    for _, button in pairs(rightListWindow.Buttons) do
                        if button.Data == selectedData then
                            button.Selected = true
                            button.Color = LCARS.ColorYellow

                            break
                        end
                    end
                end
                
                for _, selectedData in pairs(rightSelected) do
                    for _, button in pairs(leftListWindow.Buttons) do
                        if button.Data == selectedData then
                            button.Selected = true
                            button.Color = LCARS.ColorYellow

                            break
                        end
                    end
                end

                LCARS:UpdateWindow(panel, 1, leftWindow)
                LCARS:UpdateWindow(panel, 2, rightWindow)
                LCARS:UpdateWindow(panel, 3, leftListWindow)
                LCARS:UpdateWindow(panel, 4, rightListWindow)
            else
                LCARS:DisablePanel(panel)
            end
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

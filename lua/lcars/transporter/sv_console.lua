
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

            // TODO: Use Entitiy Model and Position instead
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
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
            table.insert(objects, object)
        end
    elseif mode == 3 then
        listWindow.Type = "button_list"
        -- TODO: Add Markers
    elseif mode == 4 then
        listWindow.Type = "button_list"
        -- TODO: Add Buffer
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
    "External",
    "Buffer",
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
                    Pos = screenPos + Vector(35, 12, 10),
                    Angles = screenAngle - Angle(20, -45, 0),
                    Type = "button_list",
                    Width = 600,
                    Height = 300,
                    Buttons = {}
                },
                [4] = {
                    Pos = screenPos + Vector(-35, 12, 10),
                    Angles = screenAngle - Angle(20, 45, 0),
                    Type = "button_list",
                    Width = 600,
                    Height = 300,
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

                local button = LCARS:CreateButton(targetNames[j], color)
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
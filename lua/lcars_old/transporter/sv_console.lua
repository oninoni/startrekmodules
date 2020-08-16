-- TODO: Add Other Pads Menu Option (Hide linked Pad, but show all others.) Will use Table Pos like Locations do now with multiple points being linked.
-- TODO: Add the Error Message Window. (Window 6)

-- Replace a given window's buttons with the new object list.
--
-- @param Table window
-- @param Table objects
function LCARS:ReaplaceModeButtons(window, objects)
    window.Buttons = {}

    local j = 1
    for _, object in pairs(objects) do
        local color = LCARS.ColorBlue
        if j % 2 == 0 then
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

        table.insert(window.Buttons, button)

        j = j + 1
    end
end

-- Generate the Buttons for the given transporter Pad.
-- 
-- @param Table window
-- @param Number padNumber
-- @return Table objects
function LCARS:GeneratePadButtons(window, padNumber)
    window.Type = "transport_pad"
    
    local radius = window.Height / 8
    local offset = radius * 2.5
    local outerX = 0.5 * offset
    local outerY = 0.866 * offset

    local objects = {}
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

-- Update the buttons of the given window.
--
-- @param Entity panel
-- @param Table window
-- @param Number mode
-- @param Boolean targetMenu
function LCARS:ReplaceButtons(panel, window, mode, targetMenu)
    if window.CurrentMode == mode then return end

    local objects = {}

    local modeName = panel.TargetNames[mode]
    if istable(modeName) then
        modeName = modeName[targetMenu and 2 or 1]
    end
    
    window.CurrentMode = mode

    if modeName == "Transporter Pad" then
        local padNumber = tonumber(string.sub(panel:GetName(), 11))
        objects = self:GeneratePadButtons(window, padNumber)
    end

    if modeName == "Lifeforms" then
        window.Type = "button_list"
        for _, ply in pairs(player.GetHumans()) do
            local object = {
                Name = ply:GetName(),
                Data = ply,
            }
            
            table.insert(objects, object)
        end
    end

    if modeName == "Locations" then
        window.Type = "button_list"

        local categories = {}
        for _, ent in pairs(ents.FindByName("beamLocation")) do
            local name = ent.LCARSKeyData["lcars_name"]
            categories[name] = categories[name] or {}
            table.insert(categories[name], ent)
        end

        for name, data in SortedPairs(categories) do
            local object = {
                Name = name,
                Data = data,
            }

            table.insert(objects, object)
        end
    end

    if modeName == "Buffer" then
        window.Type = "button_list"
        
        for _, ent in pairs(panel.Buffer) do
            if not IsValid(ent) then continue end

            local object = {
                Name = ent:GetName(),
                Data = ent,
            }

            if not isstring(object.Name) or object.Name == "" then
                object.Name = "Object " .. ent:EntIndex()
            end
            
            table.insert(objects, object)
        end
    end

    if modeName == "Other Pads" or modeName == "Transporter Pads"  then
        window.Type = "button_list"
        
        local consoleId = false
        local consoleName = panel:GetName()
        if isstring(consoleName) and string.StartWith(consoleName, "TRConsole") then
            local split = string.Split(consoleName, "_")
            consoleId = split[2]
        end

        local categories = {}
        for _, ent in pairs(ents.GetAll()) do
            local name = ent:GetName()
            if isstring(name) and string.StartWith(name, "TRPad") then
                local idString = string.sub(name, 6)
                local split = string.Split(idString, "_")
                local id = split[2]

                if consoleId and consoleId == id then continue end

                local padName = "Transporter Room " .. id
                categories[padName] = categories[padName] or {}
                table.insert(categories[padName], ent)
            end
        end

        for name, data in SortedPairs(categories) do
            local object = {
                Name = name,
                Data = data,
            }

            table.insert(objects, object)
        end
    end

    return self:ReaplaceModeButtons(window, objects)
end

function LCARS:OpenTransporterMenu()
    local panel = self:OpenMenuInternal(TRIGGER_PLAYER, CALLER, function(ply, panel_brush, panel, screenPos, screenAngle)
        panel.Buffer = panel.Buffer or {}
        panel.TargetNames = {
            "Transporter Pad",
            "Lifeforms",
            "Locations",
            "Other Pads",
            {"Buffer", false},
        }

        local xOffset = -panel:GetForward()
        local yOffset = panel:GetRight()
        local zOffset = panel:GetUp()

        local panelData = {
            Type = "Transporter",
            Pos = screenPos + zOffset*10,
            Windows = {
                [1] = {
                    Pos = screenPos + xOffset*22 - yOffset*3 + zOffset*12,
                    Angles = screenAngle - Angle(30, -25, 0),
                    Type = "button_list",
                    Width = 350,
                    Height = 300,
                    Buttons = {}
                },
                [2] = {
                    Pos = screenPos - xOffset*22 - yOffset*3 + zOffset*12,
                    Angles = screenAngle - Angle(30, 25, 0),
                    Type = "button_list",
                    Width = 350,
                    Height = 300,
                    Buttons = {}
                },
                [3] = {
                    Pos = screenPos + xOffset*36 + yOffset*13 + zOffset*13,
                    Angles = screenAngle - Angle(30, -65, 0),
                    Type = "button_list",
                    Width = 500,
                    Height = 500,
                    Buttons = {}
                },
                [4] = {
                    Pos = screenPos - xOffset*36 + yOffset*13 + zOffset*13,
                    Angles = screenAngle - Angle(30, 65, 0),
                    Type = "button_list",
                    Width = 500,
                    Height = 500,
                    Buttons = {}
                },
            },
        }
        
        for i=1,2,1 do
            for j=1,#(panel.TargetNames),1 do
                local color = LCARS.ColorBlue
                if (i + j)%2 == 0 then
                    color = LCARS.ColorLightBlue
                end

                local targetName = panel.TargetNames[j]
                if istable(targetName) then
                    targetName = targetName[i]
                end
                
                button = LCARS:CreateButton(targetName or "", color)
                button.DeselectedColor = color

                table.insert(panelData.Windows[i].Buttons, button)
            end
        end

        panelData.Windows[1].Selected = 2
        panelData.Windows[1].Buttons[2].Color = LCARS.ColorYellow
        panelData.Windows[2].Selected = 1
        panelData.Windows[2].Buttons[1].Color = LCARS.ColorYellow

        panelData.Windows[1].Buttons[#panel.TargetNames + 2] = LCARS:CreateButton("Narrow Beam", LCARS.ColorOrange)
        panelData.Windows[1].Buttons[#panel.TargetNames + 2].Selected = false
        panelData.Windows[2].Buttons[#panel.TargetNames + 2] = LCARS:CreateButton("Direct Transport", LCARS.ColorOrange)
        panelData.Windows[2].Buttons[#panel.TargetNames + 2].Selected = false

        panelData.Windows[1].Buttons[#panel.TargetNames + 3] = LCARS:CreateButton("Swap Sides", LCARS.ColorOrange)
        panelData.Windows[1].Buttons[#panel.TargetNames + 3].Selected = false
        panelData.Windows[2].Buttons[#panel.TargetNames + 3] = LCARS:CreateButton("Disable Console", LCARS.ColorRed)
        panelData.Windows[2].Buttons[#panel.TargetNames + 3].Selected = false

        for i=1,2,1 do
            LCARS:ReplaceButtons(panel, panelData.Windows[2 + i], panelData.Windows[i].Selected, i == 2)
        end

        self:SendPanel(panel, panelData)
    end)

    if IsValid(panel) and not panel.ActiveTransporter then
        local panelData = self.ActivePanels[panel]
        if not istable(panelData) then return end
        
        local success = LCARS:ActivateTransporter(panelData, panel)
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

function LCARS:CheckBufferMode(panelData, panel)
    local leftWindow = panelData.Windows[1]
    local rightWindow = panelData.Windows[2]

    local disableAll = false
    if rightWindow.BufferTransport and leftWindow.Selected ~= 4 then
        disableAll = true
    end
    
    local leftListWindow = panelData.Windows[3]
    local rightListWindow = panelData.Windows[4]

    if disableAll then
        for j=1,#(panel.TargetNames),1 do
            rightWindow.Buttons[j].Disabled = true
        end
    else
        for j=1,#(panel.TargetNames),1 do
            rightWindow.Buttons[j].Disabled = false
        end
    end
    
    LCARS:ReplaceButtons(panel, leftListWindow, leftWindow.Selected, false)
    LCARS:ReplaceButtons(panel, rightListWindow, rightWindow.Selected, true)

    if disableAll then
        rightListWindow.Type = ""
        rightListWindow.CurrentMode = nil
    end

    LCARS:UpdateWindow(panel, 1, leftWindow)
    LCARS:UpdateWindow(panel, 2, rightWindow)
    LCARS:UpdateWindow(panel, 3, leftListWindow)
    LCARS:UpdateWindow(panel, 4, rightListWindow)
end

-- Call FireUser on all Presses
hook.Add("LCARS.PressedCustom", "LCARS.Transporter.Pressed", function(ply, panelData, panel, panelBrush, windowId, buttonId)
    if panelData.Type ~= "Transporter" then return end
    
    local window = panelData.Windows[windowId]
    if not istable(window) then return end

    local button = window.Buttons[buttonId]
    
    if windowId == 1 or windowId == 2 then
        if not istable(button) then return end

        if buttonId >= 1 and buttonId <= #(panel.TargetNames) then
            local listWindow = panelData.Windows[2 + windowId]

            for i=1,#(panel.TargetNames),1 do
                window.Buttons[i].Color = window.Buttons[i].DeselectedColor
            end

            window.Selected = buttonId
            window.Buttons[window.Selected].Color = LCARS.ColorYellow
        else
            local buttonName = window.Buttons[buttonId].Name

            if buttonName == "Wide Beam" or buttonName == "Narrow Beam" then
                button.Selected = not button.Selected
                window.WideBeam = button.Selected

                if button.Selected then
                    button.Color = LCARS.ColorRed
                    button.Name = "Wide Beam"
                else
                    button.Color = LCARS.ColorOrange
                    button.Name = "Narrow Beam"
                end
            elseif buttonName == "Buffer Transport" or buttonName == "Direct Transport" then
                button.Selected = not button.Selected
                window.BufferTransport = button.Selected

                if button.Selected then
                    button.Color = LCARS.ColorRed
                    button.Name = "Buffer Transport"
                else
                    button.Color = LCARS.ColorOrange
                    button.Name = "Direct Transport"
                end
            elseif buttonName == "Swap Sides" then
                local leftWindow = panelData.Windows[1]
                local rightWindow = panelData.Windows[2]
                
                if istable(panel.TargetNames[leftWindow.Selected]) or istable(panel.TargetNames[rightWindow.Selected]) then
                    return
                end
                
                if rightWindow.BufferTransport then
                    return
                end

                for i=1,#(panel.TargetNames),1 do
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
                        button.Data.SwapId = i
                    end
                end
                
                local rightSelected = {}
                for i, button in pairs(rightListWindow.Buttons) do
                    if button.Selected then 
                        table.insert(rightSelected, button.Data)
                        button.Data.SwapId = i
                    end
                end

                LCARS:ReplaceButtons(panel, leftListWindow, leftWindow.Selected, false)
                LCARS:ReplaceButtons(panel, rightListWindow, rightWindow.Selected, true)

                -- TODO: Redo Swapping with buffer Mode in place

                for _, selectedData in pairs(leftSelected) do
                    for i, button in pairs(rightListWindow.Buttons) do
                        if button.Data == selectedData then
                            button.Selected = true
                            button.Color = LCARS.ColorYellow

                            break
                        end

                        if istable(button.Data) and istable(selectedData) then
                            if i == selectedData.SwapId then
                                button.Selected = true
                                button.Color = LCARS.ColorYellow

                                break
                            end
                        end
                    end
                end
                
                for _, selectedData in pairs(rightSelected) do
                    for i, button in pairs(leftListWindow.Buttons) do
                            if i == selectedData.SwapId then
                            button.Selected = true
                            button.Color = LCARS.ColorYellow

                            break
                        end

                        if istable(button.Data) and istable(selectedData) then
                            if i == j then
                                button.Selected = true
                                button.Color = LCARS.ColorYellow

                                break
                            end
                        end
                    end
                end
            elseif buttonName == "Disable Console" then 
                LCARS:DisablePanel(panel)
                return
            end
        end
        
        LCARS:CheckBufferMode(panelData, panel)
    elseif windowId == 3 or windowId == 4 then
        if not istable(button) then return end

        button.Selected = not button.Selected

        if button.Selected then
            button.Color = LCARS.ColorYellow
        else
            button.Color = button.DeselectedColor
        end

        LCARS:UpdateWindow(panel, windowId, window)
    elseif windowId == 5 then
        if not panel.ActiveTransporter then
            local panelData = LCARS.ActivePanels[panel]
            if not istable(panelData) then return end

            local success = LCARS:ActivateTransporter(panelData, panel)
            if success then
                panel.ActiveTransporter = true
                timer.Simple(10, function()
                    panel.ActiveTransporter = false
                end)
            end
        end
    end
end)
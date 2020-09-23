local function createMenuWindow(pos, angle, menuTable, padNumber)
    local buttons = {}

    for i, menuType in pairs(menuTable.MenuTypes) do
        local name
        if isstring(menuType) then
            name = menuType
        elseif istable(menuType) then
            if menuTable.Target then
                name = menuType[2]
            else
                name = menuType[1]
            end
        end
        
        if not name then continue end
    
        local color = Star_Trek.LCARS.ColorBlue
        if i%2 == 0 then
            color = Star_Trek.LCARS.ColorLightBlue
        end

        local buttonData = {
            Name = name,
            Color = color,
        }

        buttons[i] = buttonData
    end

    local menuTypeCount = #(menuTable.MenuTypes)

    local utilButtonData = {}
    if menuTable.Target then
        utilButtonData.Name = "Direct Transport"
        utilButtonData.Color = Star_Trek.LCARS.ColorOrange
    else
        utilButtonData.Name = "Narrow Beam"
        utilButtonData.Color = Star_Trek.LCARS.ColorOrange
    end
    buttons[menuTypeCount +2] = utilButtonData
    menuTable.UtilButtonId = menuTypeCount +2
    function menuTable:GetUtilButtonState()
        return self.MenuWindow.Buttons[self.UtilButtonId].SelectedCustom or false
    end
    
    local utilButtonData = {}
    if menuTable.Target then
        utilButtonData.Name = "Disable Console"
        utilButtonData.Color = Star_Trek.LCARS.ColorRed
    else
        utilButtonData.Name = "Swap Sides"
        utilButtonData.Color = Star_Trek.LCARS.ColorOrange
    end
    buttons[menuTypeCount +3] = utilButtonData

    local n = table.maxn(buttons)
    local height = n * 35 + 70

    local name = "Transporter " .. (menuTable.Target and "Target" or "Source")

    local success, menuWindow = Star_Trek.LCARS:CreateWindow("button_list", pos, angle, 30, 400, height, function(windowData, interfaceData, ent, buttonId)
        if buttonId > menuTypeCount then -- Custom Buttons
            local button = windowData.Buttons[buttonId]
            
            if buttonId == menuTypeCount+2 then
                button.SelectedCustom = not (button.SelectedCustom or false)
                if button.SelectedCustom then
                    button.Color = Star_Trek.LCARS.ColorRed
                else
                    button.Color = Star_Trek.LCARS.ColorOrange
                end

                if menuTable.Target then
                    if button.SelectedCustom then
                        button.Name = "Buffer Transport" -- TODO: Block Types non-compatible source and target types
                    else
                        button.Name = "Direct Transport"
                    end
                else
                    if button.SelectedCustom then
                        button.Name = "Wide Beam"
                    else
                        button.Name = "Narrow Beam"
                    end
                end

                return true
            elseif buttonId == menuTypeCount+3 then
                if menuTable.Target then
                    Star_Trek.LCARS:CloseInterface(ent)
                else
                    local targetMenuTable = interfaceData.TargetMenuTable
                    local sourceMenuSelectionName = menuTable.MenuTypes[menuTable.Selection]
                    local targetMenuSelectionName = menuTable.MenuTypes[targetMenuTable.Selection]
                    if istable(sourceMenuSelectionName) or istable(targetMenuSelectionName) then
                        ent:EmitSound("buttons/combine_button_locked.wav")
                        -- TODO: Replace Sound
                        return
                    else
                        local sourceWindowFunctions = Star_Trek.LCARS.Windows[menuTable.MainWindow.WindowType]
                        if not istable(sourceWindowFunctions) then
                            print("[Star Trek] Invalid Source Window Type!")
                        end

                        local targetWindowFunctions = Star_Trek.LCARS.Windows[targetMenuTable.MainWindow.WindowType]
                        if not istable(targetWindowFunctions) then
                            print("[Star Trek] Invalid Target Window Type!")
                        end
                        
                        local sourceMenuData = sourceWindowFunctions.GetData(menuTable.MainWindow)
                        local targetMenuData = targetWindowFunctions.GetData(targetMenuTable.MainWindow)

                        local sourceMenuSelection = menuTable.MenuWindow.Selection
                        local success, error = menuTable:SelectType(targetMenuTable.MenuWindow.Selection)
                        if not success then
                            print("[Star Trek] " .. error)
                        end
                        
                        local success, error = targetMenuTable:SelectType(sourceMenuSelection)
                        if not success then
                            print("[Star Trek] " .. error)
                        end

                        sourceWindowFunctions.SetData(targetMenuTable.MainWindow, sourceMenuData)
                        targetWindowFunctions.SetData(menuTable.MainWindow, targetMenuData)

                        interfaceData.Windows[targetMenuTable.MenuWindow.WindowId] = targetMenuTable.MenuWindow
                        Star_Trek.LCARS:UpdateWindow(ent, targetMenuTable.MenuWindow.WindowId)

                        interfaceData.Windows[targetMenuTable.MainWindow.WindowId] = targetMenuTable.MainWindow
                        Star_Trek.LCARS:UpdateWindow(ent, targetMenuTable.MainWindow.WindowId)

                        interfaceData.Windows[menuTable.MainWindow.WindowId] = menuTable.MainWindow
                        Star_Trek.LCARS:UpdateWindow(ent, menuTable.MainWindow.WindowId)

                        return true
                    end
                end
            end
        else 
            local success, error = menuTable:SelectType(buttonId)
            if not success then
                print("[Star Trek] " .. error)
            end

            interfaceData.Windows[menuTable.MainWindow.WindowId] = menuTable.MainWindow
            Star_Trek.LCARS:UpdateWindow(ent, menuTable.MainWindow.WindowId)

            return true
        end
    end, buttons, name)
    if not success then
        return false, menuWindow
    end

    return true, menuWindow
end

local function getSelectionName(menuTable)
    local selection = menuTable.MenuWindow.Selection
    local selectionName = menuTable.MenuTypes[selection]
    if istable(selectionName) then
        if menuTable.Target then
            selectionName = selectionName[2]
        else
            selectionName = selectionName[1]
        end
    end

    return selectionName
end

local function createMainWindow(pos, angle, menuTable, padNumber)
    local selectionName = getSelectionName(menuTable)

    -- Transport Pad Window
    if selectionName == "Transporter Pad" then
        local success, mainWindow = Star_Trek.LCARS:CreateWindow("transport_pad", pos, angle, nil, 500, 500, function(windowData, interfaceData, ent, buttonId)
            -- Does nothing special here.
        end, padNumber, selectionName)
        if not success then
            return false, mainWindow
        end

        return true, mainWindow
    end

    local callback
    local buttons = {}

    -- Button List Window
    if selectionName == "Lifeforms" then
        for _, ply in pairs(player.GetHumans()) do
            table.insert(buttons, {
                Name = ply:GetName(),
                Data = ply,
            })
        end
        table.SortByMember(buttons, "Name")

        callback = function(windowData, interfaceData, ent, buttonId)
            -- Does nothing special here.
        end
    elseif selectionName == "Locations" then
        local rooms = {}
        for _, ent in pairs(ents.FindByName("beamLocation")) do
            local name = ent.LCARSKeyData["lcars_name"]
            rooms[name] = rooms[name] or {}
            table.insert(rooms[name], ent:GetPos())
        end

        for name, locations in SortedPairs(rooms) do
            table.insert(buttons, {
                Name = name,
                Data = locations,
            })
        end

        callback = function(windowData, interfaceData, ent, buttonId)
            -- Does nothing special here.
        end
    elseif selectionName == "Buffer" then
        for _, ent in pairs(Star_Trek.Transporter.Buffer.Entities) do
            table.insert(buttons, {
                Name = ent:GetName(),
                Data = ent,
            })
        end

        callback = function(windowData, interfaceData, ent, buttonId)
            -- Does nothing special here.
        end
    elseif selectionName == "Other Pads" or selectionName == "Transporter Pads"  then
        local pads = {}
        for _, pad in pairs(ents.GetAll()) do
            local name = pad:GetName()
            if isstring(name) and string.StartWith(name, "TRPad") then
                local idString = string.sub(name, 6)
                local split = string.Split(idString, "_")
                local roomId = split[2]

                if padNumber and padNumber == roomId then continue end

                local roomName = "Transporter Room " .. roomId
                pads[roomName] = pads[roomName] or {}
                table.insert(pads[roomName], pad)
            end
        end

        for name, roomPads in SortedPairs(pads) do
            table.insert(buttons, {
                Name = name,
                Data = roomPads,
            })
        end

        callback = function(windowData, interfaceData, ent, buttonId)
            -- Does nothing special here.
        end
    else
        return false, "Invalid Menu Type"
    end

    local success, mainWindow = Star_Trek.LCARS:CreateWindow("button_list", pos, angle, nil, 500, 500, callback, buttons, selectionName, true)
    if not success then
        return false, mainWindow
    end

    return true, mainWindow
end

local function createWindowTable(menuPos, menuAngle, mainPos, mainAngle, targetSide, menuTypes, padNumber)
    local menuTable = {
        MenuTypes = menuTypes or {
            "Transporter Pad",
            "Locations",
            "Lifeforms",
            "Other Pads",
            {"Buffer", false},
        },
        Target = targetSide or false,
    }

    local success, menuWindow = createMenuWindow(menuPos, menuAngle, menuTable, padNumber)
    if not success then
        return false, "Error on MenuWindow: " .. menuWindow
    end
    menuTable.MenuWindow = menuWindow

    function menuTable:SelectType(buttonId)
        local buttons = self.MenuWindow.Buttons

        local oldSelected = self.MenuWindow.Selection
        if isnumber(oldSelected) then
            buttons[oldSelected].Selected = false
        end

        self.MenuWindow.Selection = buttonId
        buttons[buttonId].Selected = true

        local success, mainWindow = createMainWindow(mainPos, mainAngle, menuTable, padNumber)
        if not success then
            return false, "Error on MainWindow: " .. mainWindow
        end
        if istable(self.MainWindow) then
            mainWindow.WindowId = self.MainWindow.WindowId
        end        
        menuTable.MainWindow = mainWindow

        return true
    end
    
    return true, menuTable
end

local function getPatternData(menuTable, wideField)
    local selectionName = getSelectionName(menuTable)
    local mainWindow = menuTable.MainWindow
    local menuWindow = menuTable.MenuWindow

    if selectionName == "Transporter Pad" then
        local pads = {}
        for _, pad in pairs(mainWindow.Pads) do
            if pad.Selected then
                table.insert(pads, pad.Data)
            end
        end

        return Star_Trek.Transporter:GetPatternsFromPads(pads)
    elseif selectionName == "Lifeforms" then
        local players = {}
        for _, button in pairs(mainWindow.Buttons) do
            if button.Selected then
                table.insert(players, button.Data)
            end
        end

        return Star_Trek.Transporter:GetPatternsFromPlayers(players, wideField)
    elseif selectionName == "Locations" then
        local positions = {}
        for _, button in pairs(mainWindow.Buttons) do
            if button.Selected then
                for _, pos in pairs(button.Data) do
                    table.insert(positions, pos) 
                end
            end
        end

        return Star_Trek.Transporter:GetPatternsFromLocations(positions, wideField)
    elseif selectionName == "Buffer" then
        local entities = {}
        for _, button in pairs(mainWindow.Buttons) do
            if button.Selected then
                table.insert(entities, button.Data)
            end
        end

        return Star_Trek.Transporter:GetPatternsFromBuffers(entities)
    elseif selectionName == "Other Pads" or selectionName == "Transporter Pads"  then
        local pads = {}
        for _, button in pairs(mainWindow.Buttons) do
            if button.Selected then
                for _, pad in pairs(button.Data) do
                    table.insert(pads, pad)
                end
            end
        end
        
        return Star_Trek.Transporter:GetPatternsFromPads(pads)
    end
end

local function triggerTransporter(interfaceData)
    local sourceMenuTable = interfaceData.SourceMenuTable
    local targetMenuTable = interfaceData.TargetMenuTable

    local wideField = sourceMenuTable:GetUtilButtonState()
    local sourcePatterns = getPatternData(sourceMenuTable, wideField)
    local targetPatterns = getPatternData(targetMenuTable, false)

    local toBuffer = targetMenuTable:GetUtilButtonState()
    if toBuffer then
        Star_Trek.Transporter:ActivateTransporter(sourcePatterns, false)
    else
        Star_Trek.Transporter:ActivateTransporter(sourcePatterns, targetPatterns)
    end
end

-- Opening a turbolift control menu.
function Star_Trek.LCARS:OpenTransporterMenu()
    local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
    if not success then 
        print("[Star Trek] " .. ent)
        return
    end

    local padNumber = false
    local consoleName = ent:GetName()
    if isstring(consoleName) and string.StartWith(consoleName, "TRConsole") then
        local split = string.Split(consoleName, "_")
        padNumber = tonumber(split[2])
    end

    local interfaceData = self.ActiveInterfaces[ent]
    if istable(interfaceData) then
        triggerTransporter(interfaceData)
        return
    end

    local success, sourceMenuTable = createWindowTable(Vector(-13, 0, 4), Angle(5, 15, 30), Vector(-30, -10, 18), Angle(15, 45, 60), false, nil, padNumber)
    if not success then
        print("[Star Trek] " .. sourceMenuTable)
        return
    end
    local success, error = sourceMenuTable:SelectType(1)
    if not success then
        print("[Star Trek] " .. error)
    end
    
    local success, targetMenuTable = createWindowTable(Vector(13, 0, 4), Angle(-5, -15, 30), Vector(30, -10, 18), Angle(-15, -45, 60), true, nil, padNumber)
    if not success then
        print("[Star Trek] " .. targetMenuTable)
        return
    end
    local success, error = targetMenuTable:SelectType(2)
    if not success then
        print("[Star Trek] " .. error)
    end

    local windows = Star_Trek.LCARS:CombineWindows(
        sourceMenuTable.MenuWindow,
        sourceMenuTable.MainWindow,
        targetMenuTable.MenuWindow,
        targetMenuTable.MainWindow
    )

    local success, error = self:OpenInterface(ent, windows)
    if not success then
        print("[Star Trek] " .. error)
        return
    end
    
    local interfaceData = self.ActiveInterfaces[ent]
    interfaceData.SourceMenuTable = sourceMenuTable
    interfaceData.TargetMenuTable = targetMenuTable
end

-- TODO: Get rid of by changing map
LCARS = LCARS or {}
function LCARS:OpenTransporterMenu()
    Star_Trek.LCARS:OpenTransporterMenu()
end
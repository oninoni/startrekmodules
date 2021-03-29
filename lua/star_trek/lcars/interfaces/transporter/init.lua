local transporterUtil = include("util.lua")

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
		if i % 2 == 0 then
			color = Star_Trek.LCARS.ColorLightBlue
		end

		local buttonData = {
			Name = name,
			Color = color,
		}

		buttons[i] = buttonData
	end

	local menuTypeCount = #menuTable.MenuTypes

	if isnumber(padNumber) then
		local utilButtonData = {}
		if not menuTable.Target then
			utilButtonData.Name = "Narrow Beam"
			utilButtonData.Color = Star_Trek.LCARS.ColorOrange
		else
			utilButtonData.Name = "Instant Dematerialisation"
			utilButtonData.Color = Star_Trek.LCARS.ColorOrange
		end
		
		buttons[table.Count(buttons) + 2] = utilButtonData
		menuTable.UtilButtonId = menuTypeCount + 2
		
		function menuTable:GetUtilButtonState()
			return self.MenuWindow.Buttons[self.UtilButtonId].SelectedCustom or false
		end
	end

	local utilButtonData = {}
	if menuTable.Target then
		utilButtonData.Name = "Disable Console"
		utilButtonData.Color = Star_Trek.LCARS.ColorRed
	else
		utilButtonData.Name = "Swap Sides"
		utilButtonData.Color = Star_Trek.LCARS.ColorOrange
	end
	buttons[table.Count(buttons) + 2] = utilButtonData

	local height = table.maxn(buttons) * 35 + 80
	local transporterType = menuTable.Target and "Target" or "Source"
	local name = "Transporter " .. transporterType
	local success, menuWindow = Star_Trek.LCARS:CreateWindow("button_list", pos, angle, 24, 500, height, function(windowData, interfaceData, ent, buttonId)
		if buttonId > menuTypeCount then -- Custom Buttons
			local button = windowData.Buttons[buttonId]
			
			if button.Name == "Wide Beam" or button.Name == "Narrow Beam" then
				button.SelectedCustom = not (button.SelectedCustom or false)
				if button.SelectedCustom then
					button.Color = Star_Trek.LCARS.ColorRed
				else
					button.Color = Star_Trek.LCARS.ColorOrange
				end

				if button.SelectedCustom then
					button.Name = "Wide Beam"
				else
					button.Name = "Narrow Beam"
				end

				return true
			end

			if button.Name == "Instant Dematerialisation" or button.Name == "Delayed Dematerialisation" then
				button.SelectedCustom = not (button.SelectedCustom or false)
				if button.SelectedCustom then
					button.Color = Star_Trek.LCARS.ColorRed
				else
					button.Color = Star_Trek.LCARS.ColorOrange
				end
				
				if button.SelectedCustom then
					button.Name = "Delayed Dematerialisation"
				else
					button.Name = "Instant Dematerialisation"
				end

				return true
			end

			if button.Name == "Disable Console" then
				ent:EmitSound("star_trek.lcars_close")
				Star_Trek.LCARS:CloseInterface(ent)

				return false
			end

			if button.Name == "Swap Sides" then
				local targetMenuTable = interfaceData.TargetMenuTable
				local sourceMenuSelectionName = menuTable.MenuTypes[menuTable.Selection]
				local targetMenuSelectionName = menuTable.MenuTypes[targetMenuTable.Selection]
				if istable(sourceMenuSelectionName) or istable(targetMenuSelectionName) then
					ent:EmitSound("star_trek.lcars_error")

					return false
				end
			
				local sourceWindowFunctions = Star_Trek.LCARS.Windows[menuTable.MainWindow.WindowType]
				if not istable(sourceWindowFunctions) then
					Star_Trek:Message("Invalid Source Window Type!")
					return
				end

				local targetWindowFunctions = Star_Trek.LCARS.Windows[targetMenuTable.MainWindow.WindowType]
				if not istable(targetWindowFunctions) then
					Star_Trek:Message("Invalid Target Window Type!")
					return
				end

				local sourceMenuData = sourceWindowFunctions.GetSelected(menuTable.MainWindow)
				local targetMenuData = targetWindowFunctions.GetSelected(targetMenuTable.MainWindow)

				local sourceMenuSelection = menuTable.MenuWindow.Selection
				local success, error = menuTable:SelectType(targetMenuTable.MenuWindow.Selection)
				if not success then
					Star_Trek:Message(error)
					return
				end

				local success, error = targetMenuTable:SelectType(sourceMenuSelection)
				if not success then
					Star_Trek:Message(error)
					return
				end

				sourceWindowFunctions.SetSelected(targetMenuTable.MainWindow, sourceMenuData)
				targetWindowFunctions.SetSelected(menuTable.MainWindow, targetMenuData)

				Star_Trek.LCARS:UpdateWindow(ent, targetMenuTable.MenuWindow.WindowId, targetMenuTable.MenuWindow)
				Star_Trek.LCARS:UpdateWindow(ent, targetMenuTable.MainWindow.WindowId, targetMenuTable.MainWindow)
				Star_Trek.LCARS:UpdateWindow(ent, menuTable.MainWindow.WindowId, menuTable.MainWindow)

				return true
			end
		else
			local success, error = menuTable:SelectType(buttonId)
			if not success then
				Star_Trek:Message(error)
				return
			end

			Star_Trek.LCARS:UpdateWindow(ent, menuTable.MainWindow.WindowId, menuTable.MainWindow)

			return true
		end
	end, buttons, name, transporterType)
	if not success then
		return false, menuWindow
	end

	return true, menuWindow
end

local function createMainWindow(pos, angle, menuTable, padNumber)
	local selectionName = transporterUtil.GetSelectionName(menuTable)

	-- Transport Pad Window
	if selectionName == "Transporter Pad" then
		local success, mainWindow = Star_Trek.LCARS:CreateWindow("transport_pad", pos, angle, nil, 500, 500, function(windowData, interfaceData, ent, buttonId)
			-- Does nothing special here.
		end, padNumber, "Transporter Pad", "Pad")
		if not success then
			return false, mainWindow
		end

		return true, mainWindow
	end

	local callback
	local buttons = {}

	-- Category List Window
	if selectionName == "Sections" then
		local success, mainWindow = Star_Trek.LCARS:CreateWindow("category_list", pos, angle, nil, 500, 500, function(windowData, interfaceData, ent, categoryId, buttonId)
			-- Does nothing special here.
		end, Star_Trek.LCARS:GetSectionCategories(menuTable.Target), "Sections", "SECTNS", true)
		if not success then
			return false, mainWindow
		end

		return true, mainWindow
	end

	-- Button List Window
	local titleShort = ""
	if selectionName == "Lifeforms" then
		titleShort = "LIFE"

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
	elseif selectionName == "Buffer" then
		titleShort = "Buffer"

		for _, ent in pairs(Star_Trek.Transporter.Buffer.Entities) do
			local name = "Unknown Pattern"
			if ent:IsPlayer() or ent:IsNPC() then
				name = "Organic Pattern"
			end
			local className = ent:GetClass()
			if className == "prop_physics" then
				name = "Pattern"
			end
			-- TODO: Scanner implementation to identify stuff?

			table.insert(buttons, {
				Name = name,
				Data = ent,
			})
		end

		callback = function(windowData, interfaceData, ent, buttonId)
			-- Does nothing special here.
		end
	elseif selectionName == "Other Pads" or selectionName == "Transporter Pads"  then
		titleShort = "Pads"

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

	local success, mainWindow = Star_Trek.LCARS:CreateWindow("button_list", pos, angle, nil, 500, 500, callback, buttons, selectionName, titleShort, true)
	if not success then
		return false, mainWindow
	end

	return true, mainWindow
end

local function createWindowTable(menuPos, menuAngle, mainPos, mainAngle, targetSide, menuTypes, padNumber)
	local menuTable = {
		MenuTypes = menuTypes or {
			"Transporter Pad",
			"Other Pads",
			"Sections",
			"Lifeforms",
			"External",
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

		local success, mainWindow = createMainWindow(mainPos, mainAngle, self, padNumber)
		if not success then
			return false, "Error on MainWindow: " .. mainWindow
		end
		if istable(self.MainWindow) then
			mainWindow.WindowId = self.MainWindow.WindowId
		end
		self.MainWindow = mainWindow

		return true
	end

	return true, menuTable
end

function Star_Trek.LCARS:OpenTransporterMenu()
	local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
	if not success then
		Star_Trek:Message(ent)
		return
	end

	local interfaceData = self.ActiveInterfaces[ent]
	if istable(interfaceData) then
		return
	end

	local padNumber = false
	local consoleName = ent:GetName()
	if isstring(consoleName) and string.StartWith(consoleName, "TRConsole") then
		local split = string.Split(consoleName, "_")
		padNumber = tonumber(split[2])
	end

	local success, sourceMenuTable = createWindowTable(Vector(-15, -2, 6), Angle(5, 15, 30), Vector(-31, -12, 17), Angle(15, 45, 60), false, nil, padNumber)
	if not success then
		Star_Trek:Message(sourceMenuTable)
		return
	end
	local success, error = sourceMenuTable:SelectType(1)
	if not success then
		Star_Trek:Message(error)
		return
	end

	local success, targetMenuTable = createWindowTable(Vector(15, -2, 6), Angle(-5, -15, 30), Vector(31, -12, 17), Angle(-15, -45, 60), true, nil, padNumber)
	if not success then
		Star_Trek:Message(targetMenuTable)
		return
	end
	local success, error = targetMenuTable:SelectType(2)
	if not success then
		Star_Trek:Message(error)
		return
	end

	local success, sliderWindow = Star_Trek.LCARS:CreateWindow("transport_slider", Vector(0, -2, 6), Angle(0, 0, 30), 30, 200, 200, function(windowData, interfaceData, ent, buttonId)
		transporterUtil.TriggerTransporter(self.ActiveInterfaces[ent])
	end)
	if not success then
		Star_Trek:Message(sliderWindow)
		return
	end

	local windows = Star_Trek.LCARS:CombineWindows(
		sourceMenuTable.MenuWindow,
		sourceMenuTable.MainWindow,
		targetMenuTable.MenuWindow,
		targetMenuTable.MainWindow,
		sliderWindow
	)

	local success, error = self:OpenInterface(ent, windows)
	if not success then
		Star_Trek:Message(error)
		return
	end

	local interfaceData = self.ActiveInterfaces[ent]
	interfaceData.SourceMenuTable = sourceMenuTable
	interfaceData.TargetMenuTable = targetMenuTable
end

function Star_Trek.LCARS:OpenConsoleTransporterMenu()
	local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
	if not success then
		Star_Trek:Message(ent)
		return
	end

	local interfaceData = self.ActiveInterfaces[ent]
	if istable(interfaceData) then
		return
	end

	local menuTypes = {
		"Lifeforms",
		"Transporter Pads",
		"Sections",
		"External",
	}
	
	local success, sourceMenuTable = createWindowTable(Vector(-22, -34, 8.2), Angle(0, 0, -90), Vector(-22, 0, 0), Angle(0, 0, 0), false, menuTypes)
	if not success then
		Star_Trek:Message(sourceMenuTable)
		return
	end
	local success, error = sourceMenuTable:SelectType(1)
	if not success then
		Star_Trek:Message(error)
		return
	end

	local success, targetMenuTable = createWindowTable(Vector(22, -34, 8.2), Angle(0, 0, -90), Vector(22, 0, 0), Angle(0, 0, 0), true, menuTypes)
	if not success then
		Star_Trek:Message(targetMenuTable)
		return
	end
	local success, error = targetMenuTable:SelectType(2)
	if not success then
		Star_Trek:Message(error)
		return
	end

	local success, sliderWindow = Star_Trek.LCARS:CreateWindow("transport_slider", Vector(0, -34, 8), Angle(0, 0, -90), 20, 200, 200, function(windowData, interfaceData, ent, buttonId)
		transporterUtil.TriggerTransporter(self.ActiveInterfaces[ent])
	end)
	if not success then
		Star_Trek:Message(sliderWindow)
		return
	end

	local windows = Star_Trek.LCARS:CombineWindows(
		sourceMenuTable.MenuWindow,
		sourceMenuTable.MainWindow,
		targetMenuTable.MenuWindow,
		targetMenuTable.MainWindow,
		sliderWindow
	)

	local success, error = self:OpenInterface(ent, windows)
	if not success then
		Star_Trek:Message(error)
		return
	end

	interfaceData = self.ActiveInterfaces[ent]
	interfaceData.SourceMenuTable = sourceMenuTable
	interfaceData.TargetMenuTable = targetMenuTable
end
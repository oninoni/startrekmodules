local transporterUtil = include("util.lua")

function transporterUtil.CreateMenuWindow(pos, angle, width, menuTable, hFlip, padNumber)
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
	local success, menuWindow = Star_Trek.LCARS:CreateWindow(
		"button_list",
		pos,
		angle,
		24,
		width,
		height,
		function(windowData, interfaceData, buttonId)
			local ent = windowData.Ent

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

					local sourceMenuData = menuTable.MainWindow:GetSelected()
					local targetMenuData = targetMenuTable.MainWindow:GetSelected()

					local sourceMenuSelection = menuTable.MenuWindow.Selection
					local success2, error2 = menuTable:SelectType(targetMenuTable.MenuWindow.Selection)
					if not success2 then
						Star_Trek:Message(error2)
						return
					end

					local success3, error3 = targetMenuTable:SelectType(sourceMenuSelection)
					if not success3 then
						Star_Trek:Message(error3)
						return
					end

					targetMenuTable.MainWindow:SetSelected(sourceMenuData)
					menuTable.MainWindow:SetSelected(targetMenuData)

					Star_Trek.LCARS:UpdateWindow(ent, targetMenuTable.MenuWindow.Id, targetMenuTable.MenuWindow)
					Star_Trek.LCARS:UpdateWindow(ent, targetMenuTable.MainWindow.Id, targetMenuTable.MainWindow)
					Star_Trek.LCARS:UpdateWindow(ent, menuTable.MainWindow.Id, menuTable.MainWindow)

					return true
				end
			else
				local success4, error4 = menuTable:SelectType(buttonId)
				if not success4 then
					Star_Trek:Message(error4)
					return
				end

				Star_Trek.LCARS:UpdateWindow(ent, menuTable.MainWindow.Id, menuTable.MainWindow)

				return true
			end
		end,
		buttons,
		name,
		transporterType,
		hFlip
	)
	if not success then
		return false, menuWindow
	end

	return true, menuWindow
end

function transporterUtil.CreateMainWindow(pos, angle, width, height, menuTable, hFlip, padNumber)
	local selectionName = transporterUtil.GetSelectionName(menuTable)

	-- Transport Pad Window
	if selectionName == "Transporter Pad" then
		local success, mainWindow = Star_Trek.LCARS:CreateWindow(
			"transport_pad",
			pos,
			angle,
			nil,
			width,
			height,
			function(windowData, interfaceData, buttonId)
				-- Does nothing special here.
			end,
			padNumber,
			"Transporter Pad",
			"Pad",
			hFlip
		)
		if not success then
			return false, mainWindow
		end

		return true, mainWindow
	end

	-- Category List Window
	if selectionName == "Sections" then
		local success, mainWindow = Star_Trek.LCARS:CreateWindow(
			"category_list",
			pos,
			angle,
			nil,
			width,
			height,
			function(windowData, interfaceData, categoryId, buttonId)
				-- Does nothing special here.
			end,
			Star_Trek.LCARS:GetSectionCategories(menuTable.Target),
			"Sections",
			"SECTNS",
			hFlip,
			true
		)
		if not success then
			return false, mainWindow
		end

		return true, mainWindow
	end

	local callback
	local buttons = {}

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

		callback = function(windowData, interfaceData, buttonId)
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

		callback = function(windowData, interfaceData, buttonId)
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

		callback = function(windowData, interfaceData, buttonId)
			-- Does nothing special here.
		end
	else
		return false, "Invalid Menu Type"
	end

	local success, mainWindow = Star_Trek.LCARS:CreateWindow(
		"button_list",
		pos,
		angle,
		nil,
		width,
		height,
		callback,
		buttons,
		selectionName,
		titleShort,
		hFlip,
		true
	)
	if not success then
		return false, mainWindow
	end

	return true, mainWindow
end

function transporterUtil.CreateWindowTable(menuPos, menuAngle, menuWidth, menuHFlip, mainPos, mainAngle, mainWidth, mainHeight, mainHFlip, targetSide, padNumber)
	local menuTypes = {
		"Lifeforms",
		"Transporter Pads",
		"Sections",
		"External",
	}

	if padNumber then
		menuTypes = {
			"Transporter Pad",
			"Other Pads",
			"Sections",
			"Lifeforms",
			"External",
			{"Buffer", false},
		}
	end

	local menuTable = {
		MenuTypes = menuTypes,
		Target = targetSide or false,
	}

	local success, menuWindow = transporterUtil.CreateMenuWindow(menuPos, menuAngle, menuWidth, menuTable, menuHFlip, padNumber)
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

		local success2, mainWindow = transporterUtil.CreateMainWindow(mainPos, mainAngle, mainWidth, mainHeight, self, mainHFlip, padNumber)
		if not success2 then
			return false, "Error on MainWindow: " .. mainWindow
		end
		if istable(self.MainWindow) then
			mainWindow.Id = self.MainWindow.Id
		end
		self.MainWindow = mainWindow

		return true
	end

	return true, menuTable
end

return transporterUtil
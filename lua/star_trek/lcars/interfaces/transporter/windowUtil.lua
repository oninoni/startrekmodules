---------------------------------------
---------------------------------------
--        Star Trek Utilities        --
--                                   --
--            Created by             --
--       Jan 'Oninoni' Ziegler       --
--                                   --
-- This software can be used freely, --
--    but only distributed by me.    --
--                                   --
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--  LCARS Transporter | Window Util  --
---------------------------------------

local transporterUtil = include("util.lua")

-- Create the menu window for a transporter screen.
--
-- @param Vector pos
-- @param Angle angle
-- @param Number width
-- @param Table menuTable
-- @param? Boolean hFlip
-- @param? Number padNumber
-- @return Boolean success 
-- @return Table menuWindow
function transporterUtil.CreateMenuWindow(pos, angle, width, menuTable, hFlip, padNumber)
	local buttons = {}

	for i, menuType in pairs(menuTable.MenuTypes) do
		local name = transporterUtil.GetMenuType(menuType, menuTable.Target)

		local color = Star_Trek.LCARS.ColorBlue
		if i % 2 == 0 then
			color = Star_Trek.LCARS.ColorLightBlue
		end

		local button = {
			Name = name,
			Color = color,
		}

		-- TODO: Temporary disable External
		if name == "External" then
			button.Disabled = true
		end

		table.insert(buttons, button)
	end

	local n = #buttons

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
		menuTable.UtilButtonId = n + 2

		function menuTable:GetUtilButtonState()
			return self.MenuWindow.Buttons[self.UtilButtonId].SelectedCustom or false
		end
	end

	local actionButtonData = {}
	if menuTable.Target then
		actionButtonData.Name = "Disable Console"
		actionButtonData.Color = Star_Trek.LCARS.ColorRed
	else
		actionButtonData.Name = "Swap Sides"
		actionButtonData.Color = Star_Trek.LCARS.ColorOrange
	end
	buttons[table.Count(buttons) + 2] = actionButtonData

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
			if buttonId > n then -- Custom Buttons
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
					windowData:Close()

					return false
				end

				if button.Name == "Swap Sides" then
					local targetMenuTable = interfaceData.TargetMenuTable
					local sourceMenuSelectionName = transporterUtil.GetSelectedMenuType(menuTable)
					local targetMenuSelectionName = transporterUtil.GetSelectedMenuType(targetMenuTable)
					if istable(sourceMenuSelectionName) or istable(targetMenuSelectionName) then
						windowData.Ent:EmitSound("star_trek.lcars_error")

						return false
					end

					local sourceMenuData = menuTable.MainWindow:GetSelected()
					local targetMenuData = targetMenuTable.MainWindow:GetSelected()

					local success2, error2 = menuTable:SelectType(targetMenuSelectionName)
					if not success2 then
						Star_Trek:Message(error2)
						return
					end

					local success3, error3 = targetMenuTable:SelectType(sourceMenuSelectionName)
					if not success3 then
						Star_Trek:Message(error3)
						return
					end

					targetMenuTable.MainWindow:SetSelected(sourceMenuData)
					menuTable.MainWindow:SetSelected(targetMenuData)

					-- Update All Windows (Source Menu Window gets updated automatically)
					targetMenuTable.MenuWindow:Update()
					targetMenuTable.MainWindow:Update()
					menuTable.MainWindow:Update()

					return true
				end
			else
				local success4, error4 = menuTable:SelectType(menuTable.MenuTypes[buttonId])
				if not success4 then
					Star_Trek:Message(error4)
					return
				end

				-- Update Main Window (Source Menu Window gets updated automatically)
				menuTable.MainWindow:Update()

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

-- @param Vector pos
-- @param Angle angle
-- @param Number width
-- @param Number height
-- @param Table menuTable
-- @param? Boolean hFlip
-- @param? Number padNumber
-- @return Boolean success 
-- @return Table mainWindow
function transporterUtil.CreateMainWindow(pos, angle, width, height, menuTable, hFlip, padNumber)
	local modeName = transporterUtil.GetMode(menuTable)

	-- Transport Pad Window
	if modeName == "Transporter Pad" then
		local success, mainWindow = Star_Trek.LCARS:CreateWindow(
			"transport_pad",
			pos,
			angle,
			nil,
			width,
			height,
			nil,
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
	if modeName == "Sections" then
		local success, mainWindow = Star_Trek.LCARS:CreateWindow(
			"category_list",
			pos,
			angle,
			nil,
			width,
			height,
			nil,
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

	-- Button List Window
	local titleShort = ""
	local buttons = {}

	if modeName == "Lifeforms" then
		titleShort = "LIFE"

		for _, ply in pairs(player.GetHumans()) do
			table.insert(buttons, {
				Name = ply:GetName(),
				Data = ply,
			})
		end
		table.SortByMember(buttons, "Name")
	elseif modeName == "Buffer" then
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
	elseif modeName == "Other Pads" or modeName == "Transporter Pads"  then
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
		nil,
		buttons,
		modeName,
		titleShort,
		hFlip,
		true
	)
	if not success then
		return false, mainWindow
	end

	return true, mainWindow
end

-- Create the Window Pair for one side of the transporter interface.
--
-- @param Vector menuPos
-- @param Angle menuAngle
-- @param Number menuWidth
-- @param Boolean menuHFlip
-- @param Vector mainPos
-- @param Angle mainAngle
-- @param Number mainWidth
-- @param Number mainHeight
-- @param Boolean mainHFlip
-- @param Boolean targetSide
-- @param? Number padNumber
-- @return Boolean success 
-- @return Table mainWindow
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

	function menuTable:SelectType(name)
		menuTable.MenuWindow:SetSelected({
			[name] = true,
		})

		local success2, mainWindow = transporterUtil.CreateMainWindow(mainPos, mainAngle, mainWidth, mainHeight, self, mainHFlip, padNumber)
		if not success2 then
			return false, "Error on MainWindow: " .. mainWindow
		end
		if istable(self.MainWindow) then
			mainWindow.Id = self.MainWindow.Id
			mainWindow.Ent = self.MainWindow.Ent
		end
		self.MainWindow = mainWindow

		return true
	end

	return true, menuTable
end

return transporterUtil
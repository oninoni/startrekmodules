---------------------------------------
---------------------------------------
--         Star Trek Modules         --
--                                   --
--            Created by             --
--       Jan 'Oninoni' Ziegler       --
--                                   --
-- This software can be used freely, --
--    but only distributed by me.    --
--                                   --
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--  LCARS Transporter | Window Util  --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

-- Create the menu window for a transporter screen.
--
-- @param Vector pos
-- @param Angle angle
-- @param Number width
-- @param Table menuTable
-- @param? Boolean hFlip
-- @return Boolean success 
-- @return Table menuWindow
function SELF:CreateMenuWindow(pos, angle, width, menuTable, hFlip)
	local buttons = {}
	local n = 0
	for i, menuType in pairs(menuTable.MenuTypes) do
		local name = self:GetMenuType(menuType, menuTable.Target)
		if not name then continue end

		n = n + 1

		local color = Star_Trek.LCARS.ColorBlue
		if i % 2 == 0 then
			color = Star_Trek.LCARS.ColorLightBlue
		end

		local button = {
			Name = name,
			Color = color,
		}

		table.insert(buttons, button)
	end
	local realN = n

	if self.AdvancedMode then
		local utilButtonData = {}
		if not menuTable.Target then
			utilButtonData.Name = "Narrow Beam"
			utilButtonData.Color = Star_Trek.LCARS.ColorOrange
		else
			utilButtonData.Name = "Instant Dematerialisation"
			utilButtonData.Color = Star_Trek.LCARS.ColorOrange
		end

		buttons[n + 2] = utilButtonData
		menuTable.UtilButtonId = n + 2
		n = n + 1

		local weaponButtonData = {}
		if menuTable.Target then
			weaponButtonData.Name = "Allow Weapons"
			weaponButtonData.Color = Star_Trek.LCARS.ColorOrange
		else
			weaponButtonData.Name = "Purge Buffer"
			weaponButtonData.Color =  Star_Trek.LCARS.ColorRed
		end
		buttons [n + 2] = weaponButtonData
		menuTable.WeaponButtonId = n + 2
		n = n + 1

		function menuTable:GetUtilButtonState()
			return self.MenuWindow.Buttons[#self.MenuWindow.Buttons - 2].SelectedCustom or false
		end

		function menuTable:GetWeaponsButtonState()
			return not self.MenuWindow.Buttons[#self.MenuWindow.Buttons - 1].SelectedCustom or false
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
	buttons[n + 2] = actionButtonData
	menuTable.ActionButtonId = n + 2

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
		function(windowData, interfaceData, ply, buttonId, buttonData)

			if buttonId > realN then -- Custom Buttons
				if buttonData.Name == "Wide Beam" or buttonData.Name == "Narrow Beam" then
					buttonData.SelectedCustom = not (buttonData.SelectedCustom or false)
					if buttonData.SelectedCustom then
						buttonData.Color = Star_Trek.LCARS.ColorRed
					else
						buttonData.Color = Star_Trek.LCARS.ColorOrange
					end

					if buttonData.SelectedCustom then
						buttonData.Name = "Wide Beam"
					else
						buttonData.Name = "Narrow Beam"
					end

					return true
				end

				if buttonData.Name == "Instant Dematerialisation" or buttonData.Name == "Delayed Dematerialisation" then
					buttonData.SelectedCustom = not (buttonData.SelectedCustom or false)
					if buttonData.SelectedCustom then
						buttonData.Color = Star_Trek.LCARS.ColorRed
					else
						buttonData.Color = Star_Trek.LCARS.ColorOrange
					end

					if buttonData.SelectedCustom then
						buttonData.Name = "Delayed Dematerialisation"
					else
						buttonData.Name = "Instant Dematerialisation"
					end

					return true
				end

				if buttonData.Name == "Remove Weapons" or buttonData.Name == "Allow Weapons" then
					buttonData.SelectedCustom = not (buttonData.SelectedCustom or false)
					if buttonData.SelectedCustom then
						buttonData.Color = Star_Trek.LCARS.ColorRed
					else
						buttonData.Color = Star_Trek.LCARS.ColorOrange
					end

					if buttonData.SelectedCustom then
						buttonData.Name = "Remove Weapons"
					else
						buttonData.Name = "Allow Weapons"
					end

					return true
				end

				if buttonData.Name == "Purge Buffer" then
					Star_Trek.Logs:AddEntry(self.Ent, ply, "WARNING: Purging Buffer!", Star_Trek.LCARS.ColorRed)
					for _,ent in pairs(Star_Trek.Transporter.Buffer.Entities) do
						ent.BufferQuality = 0
						local success1, scanData = Star_Trek.Sensors:ScanEntity(ent)
						if success1 then
							Star_Trek.Logs:AddEntry(self.Ent, ply, "PURGING: " .. scanData.Name , Star_Trek.LCARS.ColorRed)
						end
					end
				
					self.Ent:EmitSound("star_trek.lcars_purge_beep")

					Star_Trek.Logs:AddEntry(self.Ent, ply, "Purge Complete", Star_Trek.LCARS.ColorRed)
				end

				if buttonData.Name == "Disable Console" then
					windowData:Close()

					return false
				end

				if buttonData.Name == "Swap Sides" then
					local targetMenuTable = menuTable.TargetMenuTable
					local sourceMenuSelectionName = self:GetSelectedMenuType(menuTable)
					local targetMenuSelectionName = self:GetSelectedMenuType(targetMenuTable)
					if sourceMenuSelectionName == "Buffer" then
						interfaceData.Ent:EmitSound("star_trek.lcars_error")

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
-- @return Boolean success 
-- @return Table mainWindow
function SELF:CreateMainWindow(pos, angle, width, height, menuTable, hFlip)
	local modeName = self:GetMode(menuTable)

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
			self.PadEntities or {},
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
			Star_Trek.Sections:GetSectionCategories(menuTable.Target and 1),
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

	if modeName == "Crew" then
		titleShort = "CREW"

		for _, ply in pairs(player.GetHumans()) do
			if hook.Run("Star_Trek.Transporter.CheckLifeforms", ply) == false then
				continue
			end

			if table.HasValue(Star_Trek.Transporter.Buffer.Entities, ply) then
				return
			end

			table.insert(buttons, {
				Name = ply:GetName(),
				Data = ply,
			})
		end
		table.SortByMember(buttons, "Name")
	elseif modeName == "Buffer" then
		titleShort = "Buffer"

		for _, ent in pairs(Star_Trek.Transporter.Buffer.Entities) do
			if not IsValid(ent) then
				continue
			end

			local success, scanData = Star_Trek.Sensors:ScanEntity(ent)
			if success then
				name = scanData.Name
			end

			table.insert(buttons, {
				Name = name,
				Data = ent,
			})
		end
	elseif modeName == "Transporter Rooms" then
		titleShort = "Rooms"

		local pads = Star_Trek.Transporter:GetTransporterRooms(self)

		for _, roomData in SortedPairs(pads) do
			table.insert(buttons, {
				Name = roomData.Name,
				Data = roomData.Pads,
			})
		end
	elseif modeName == "External Sensors" then
		titleShort = "External"

		local externalMarkers = Star_Trek.Transporter:GetExternalMarkers(self)
		for _, externalData in pairs(externalMarkers) do
			table.insert(buttons, {
				Name = externalData.Name,
				Data = externalData.Pos,
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
-- @param Vector mainPos
-- @param Angle mainAngle
-- @param Number mainWidth
-- @param Number mainHeight
-- @param Boolean hFlip
-- @param Boolean targetSide
-- @return Boolean success 
-- @return Table mainWindow
function SELF:CreateWindowTable(menuPos, menuAngle, menuWidth, mainPos, mainAngle, mainWidth, mainHeight, hFlip, targetSide)
	local menuTypes = {
		"Crew",
		"Transporter Rooms",
		"Sections",
		"External Sensors",
	}
	if istable(self.PadEntities) and table.Count(self.PadEntities) > 0 then
		menuTypes = {
			"Transporter Pad",
			"Transporter Rooms",
			"Sections",
			"Crew",
			"External Sensors",
		}
	end

	if self.AdvancedMode then
		table.insert(menuTypes, {"Buffer", nil})
	end

	local menuTable = {
		MenuTypes = menuTypes,
		Target = targetSide or false,
	}

	local success, menuWindow = self:CreateMenuWindow(menuPos, menuAngle, menuWidth, menuTable, hFlip)
	if not success then
		return false, "Error on MenuWindow: " .. menuWindow
	end
	menuTable.MenuWindow = menuWindow

	local interfaceData = self
	function menuTable:SelectType(menuType)
		local name = interfaceData:GetMenuType(menuType, self.Target)
		menuTable.MenuWindow:SetSelected({
			[name] = true,
		})

		local success2, mainWindow = interfaceData:CreateMainWindow(mainPos, mainAngle, mainWidth, mainHeight, menuTable, hFlip)
		if not success2 then
			return false, "Error on MainWindow: " .. mainWindow
		end
		if istable(self.MainWindow) then
			mainWindow.Id = self.MainWindow.Id
			mainWindow.Interface = self.MainWindow.Interface
		end
		self.MainWindow = mainWindow

		return true
	end

	local defaultMenuType = targetSide and menuTable.MenuTypes[2] or menuTable.MenuTypes[1]
	local selectSuccess, selectError = menuTable:SelectType(defaultMenuType)
	if not selectSuccess then
		return false, selectError
	end

	return true, menuTable
end
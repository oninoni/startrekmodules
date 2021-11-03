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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--    LCARS Bridge Security | Util   --
---------------------------------------

local SELF = INTERFACE

local MODE_SCAN = 1
local MODE_BLOCK = 2
local MODE_ALERT = 3

function SELF:GetModeButtons(mode)
	mode = mode or MODE_SCAN

	local actions = {}
	local actionColors = {}
	if mode == MODE_SCAN then
		actions = {
			[1] = "Scan Lifeforms",
			[2] = "Scan Objects",
			[3] = "Scan Weapons",
			[6] = "Scan All",
		}
		actionColors = {
			[6] = Star_Trek.LCARS.ColorOrange,
		}
	elseif mode == MODE_BLOCK then
		actions = {
			[1] = "Lock Doors",
			[2] = "Unlock Doors",
			[3] = "Enable Forcefields",
			[4] = "Disable Forcefields",
			[6] = "Unlock All",
		}
		actionColors = {
			[6] = Star_Trek.LCARS.ColorOrange,
		}
	elseif mode == MODE_ALERT then
		actions = {
			[1] = "Red Alert",
			[2] = "Yellow Alert",
			[3] = "Intruder Alert",
			[4] = "Blue Alert",
			[6] = "Disable Alert",
		}
		actionColors = {
			[1] = Star_Trek.LCARS.ColorRed,
			[2] = Star_Trek.LCARS.ColorOrange,
			[6] = Star_Trek.LCARS.ColorOrange,
		}
	end

	local buttons = {}
	for i, name in pairs(actions) do
		local color = actionColors[i]
		if not color then
			if i % 2 == 0 then
				color = Star_Trek.LCARS.ColorLightBlue
			else
				color = Star_Trek.LCARS.ColorBlue
			end
		end

		buttons[i] = {
			Name = name,
			Color = color,
		}
	end

	return buttons
end

hook.Add("Star_Trek.Util.IsLifeForm", "CheckDefault", function(ent)
	if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
		return true
	end
end)

function SELF:CreateActionWindow(pos, ang, width, flip, mode)
	local buttons = self:GetModeButtons(mode)
	local height = table.maxn(buttons) * 35 + 80
	local success, actionWindow = Star_Trek.LCARS:CreateWindow(
		"button_list",
		pos,
		ang,
		24,
		width,
		height,
		function(windowData, interfaceData, buttonId)
			local buttonName = windowData.Buttons[buttonId].Name
			local sectionWindow = interfaceData.Windows[2]
			local mapWindow = interfaceData.Windows[3]
			local textWindow = interfaceData.Windows[5]
			local sectionIds = {}
			for _, buttonData in pairs(sectionWindow.Buttons) do
				if buttonData.Selected then
					table.insert(sectionIds, buttonData.Data)
				end
			end

			local deck = sectionWindow.Selected

			-- TODO: Redo using Sensors Module!

			-------- Scan --------
			if buttonName == "Scan Lifeforms" then
				local entities = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if not hook.Run("Star_Trek.Util.IsLifeForm", ent) then return true end
				end)

				mapWindow:SetObjects(entities)
				mapWindow:Update()

				for _, ent in pairs(entities) do
					local sectionName = Star_Trek.Sections:GetSectionName(deck, ent.DetectedInSection)

					textWindow:AddLine("Lifeform found in " .. sectionName .. " at " .. tostring(ent:GetPos()))
				end
				textWindow:AddLine("Total: " .. table.Count(entities) .. " Lifeforms found.", Star_Trek.LCARS.ColorRed)
				textWindow:AddLine("")
				textWindow:Update()

				return true
			elseif buttonName == "Scan Objects" then
				local entities = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if hook.Run("Star_Trek.Util.IsLifeForm", ent) then return true end
				end)

				mapWindow:SetObjects(entities)
				mapWindow:Update()

				for _, ent in pairs(entities) do
					local sectionName = Star_Trek.Sections:GetSectionName(deck, ent.DetectedInSection)

					textWindow:AddLine("Object found in " .. sectionName .. " at " .. tostring(ent:GetPos()))
				end
				textWindow:AddLine("Total: " .. table.Count(entities) .. " Non-Lifeforms found.", Star_Trek.LCARS.ColorRed)
				textWindow:AddLine("")
				textWindow:Update()

				return true
			elseif buttonName == "Scan Weapons" then

				return true
			elseif buttonName == "Scan All" then
				local entities = Star_Trek.Sections:GetInSections(deck, sectionIds)

				mapWindow:SetObjects(entities)
				mapWindow:Update()

				local lifeforms = 0
				local objects = 0
				for _, ent in pairs(entities) do
					local sectionName = Star_Trek.Sections:GetSectionName(deck, ent.DetectedInSection)

					if hook.Run("Star_Trek.Util.IsLifeForm", ent) then
						textWindow:AddLine("Lifeform found in " .. sectionName .. " at " .. tostring(ent:GetPos()))
						lifeforms = lifeforms + 1
					else
						textWindow:AddLine("Object found in " .. sectionName .. " at " .. tostring(ent:GetPos()))
						objects = objects + 1
					end
				end
				textWindow:AddLine("Total: " .. lifeforms .. " Lifeforms found.", Star_Trek.LCARS.ColorOrange)
				textWindow:AddLine("Total: " .. objects .. " Non-Lifeforms found.", Star_Trek.LCARS.ColorOrange)
				textWindow:AddLine("Total: " .. lifeforms + objects .. " Objects found.", Star_Trek.LCARS.ColorRed)
				textWindow:AddLine("")
				textWindow:Update()

				return true

			-------- Lockdown --------
			elseif buttonName == "Lock Doors" then
				local doors = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if Star_Trek.Security.Doors[ent] then
						return
					end

					return true
				end, true)

				for _, door in pairs(doors) do
					door:Fire("AddOutput", "lcars_locked 1")

					local sectionName = Star_Trek.Sections:GetSectionName(deck, door.DetectedInSection)
					textWindow:AddLine("Door #" .. door:MapCreationID() .. " in " .. sectionName .. " has been locked.")
				end

				mapWindow:SetObjects(doors)
				mapWindow:Update()

				textWindow:AddLine("Total: " .. table.Count(doors) .. " Doors locked.", Star_Trek.LCARS.ColorRed)
				textWindow:AddLine("")
				textWindow:Update()

				return true
			elseif buttonName == "Unlock Doors" then
				local doors = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if Star_Trek.Security.Doors[ent] then
						return
					end

					return true
				end, true)

				for _, door in pairs(doors) do
					door:Fire("AddOutput", "lcars_locked 0")

					local sectionName = Star_Trek.Sections:GetSectionName(deck, door.DetectedInSection)
					textWindow:AddLine("Door #" .. door:MapCreationID() .. " in " .. sectionName .. " has been unlocked.")
				end

				mapWindow:SetObjects(doors)
				mapWindow:Update()

				textWindow:AddLine("Total: " .. table.Count(doors) .. " Doors unlocked.", Star_Trek.LCARS.ColorRed)
				textWindow:AddLine("")
				textWindow:Update()

				return true
			elseif buttonName == "Enable Forcefields" then
				local success1, forceFieldPositions = Star_Trek.Security:EnableForceFieldsInSections(deck, sectionIds)
				if not success1 then
					return
				end

				local objects = {}
				for _, posData in pairs(forceFieldPositions) do
					local objectTable = {
						Pos = posData.Pos,
						Color = Star_Trek.LCARS.ColorBlue,
					}

					table.insert(objects, objectTable)

					local sectionName = Star_Trek.Sections:GetSectionName(deck, posData.DetectedInSection)
					textWindow:AddLine("Force Field in " .. sectionName .. " has been enabled.")
				end

				mapWindow:SetObjects(objects)
				mapWindow:Update()

				textWindow:AddLine("Total: " .. table.Count(forceFieldPositions) .. " Forcefields enabled.", Star_Trek.LCARS.ColorRed)
				textWindow:AddLine("")
				textWindow:Update()

				return true
			elseif buttonName == "Disable Forcefields" then
				local success1, forceFieldPositions = Star_Trek.Security:DisableForceFieldsInSections(deck, sectionIds)
				if not success1 then
					return
				end

				local objects = {}
				for _, posData in pairs(forceFieldPositions) do
					local objectTable = {
						Pos = posData.Pos,
						Color = Star_Trek.LCARS.ColorBlue,
					}

					table.insert(objects, objectTable)

					local sectionName = Star_Trek.Sections:GetSectionName(deck, posData.DetectedInSection)
					textWindow:AddLine("Force Field in " .. sectionName .. " has been disabled.")
				end

				mapWindow:SetObjects(objects)
				mapWindow:Update()

				textWindow:AddLine("Total: " .. table.Count(forceFieldPositions) .. " Forcefields disabled.", Star_Trek.LCARS.ColorRed)
				textWindow:AddLine("")
				textWindow:Update()

				return true
			elseif buttonName == "Unlock All" then
				local doors = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if Star_Trek.Security.Doors[ent] then
						return
					end

					return true
				end, true)

				local success1, forceFieldPositions = Star_Trek.Security:DisableForceFieldsInSections(deck, sectionIds)
				if not success1 then
					return
				end

				for _, door in pairs(doors) do
					door:Fire("AddOutput", "lcars_locked 0")

					local sectionName = Star_Trek.Sections:GetSectionName(deck, door.DetectedInSection)
					textWindow:AddLine("Door #" .. door:MapCreationID() .. " in " .. sectionName .. " has been unlocked.")
				end

				mapWindow:SetObjects(doors)
				for _, posData in pairs(forceFieldPositions) do
					local objectTable = {
						Pos = posData.Pos,
						Color = Star_Trek.LCARS.ColorBlue,
					}

					table.insert(mapWindow.Objects, objectTable)

					local sectionName = Star_Trek.Sections:GetSectionName(deck, posData.DetectedInSection)
					textWindow:AddLine("Force Field in " .. sectionName .. " has been disabled.")
				end

				mapWindow:Update()

				textWindow:AddLine("Total: " .. table.Count(doors) .. " Doors unlocked.", Star_Trek.LCARS.ColorOrange)
				textWindow:AddLine("Total: " .. table.Count(forceFieldPositions) .. " Forcefields disabled.", Star_Trek.LCARS.ColorOrange)
				textWindow:AddLine("Total: " .. table.Count(forceFieldPositions) + table.Count(doors) .. " Security Measures disabled.", Star_Trek.LCARS.ColorRed)
				textWindow:AddLine("")
				textWindow:Update()

				return true

			-------- Alerts --------
			elseif buttonName == "Red Alert" then
				Star_Trek.Alert:Enable("red")

				textWindow:AddLine("RED ALERT!", Star_Trek.LCARS.ColorRed)
				textWindow:AddLine("")
				textWindow:Update()

				return true
			elseif buttonName == "Yellow Alert" then
				Star_Trek.Alert:Enable("yellow")

				textWindow:AddLine("YELLOW ALERT!", Star_Trek.LCARS.ColorYellow)
				textWindow:AddLine("")
				textWindow:Update()

				return true
			elseif buttonName == "Intruder Alert" then
				Star_Trek.Alert:Enable("intruder")

				textWindow:AddLine("INTRUDER ALERT!", Star_Trek.LCARS.ColorYellow)
				textWindow:AddLine("")
				textWindow:Update()

				return true
			elseif buttonName == "Blue Alert" then
				Star_Trek.Alert:Enable("blue")

				textWindow:AddLine("BLUE ALERT!", Star_Trek.LCARS.ColorBlue)
				textWindow:AddLine("")
				textWindow:Update()

				return true
			elseif buttonName == "Disable Alert" then
				Star_Trek.Alert:Disable()

				textWindow:AddLine("Alerts Disabled!")
				textWindow:AddLine("")
				textWindow:Update()

				return true
			end
		end,
		buttons,
		"Stuff",
		nil,
		flip
	)
	if not success then
		return false, actionWindow
	end

	return true, actionWindow
end

function SELF:CreateMenuWindow(pos, ang, width, actionPos, actionAng, actionWidth, flipAction)
	local success, actionWindow = self:CreateActionWindow(actionPos, actionAng, actionWidth, flipAction, 1)
	if not success then
		return false, actionWindow
	end

	local modes = {
		"Internal Scanners",
		"Security Measures",
		"Alerts",
	}
	local buttons = {}
	for i, name in pairs(modes) do
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

	local modeCount = #modes
	local utilButtonData = {
		Name = "Disable Console",
		Color = Star_Trek.LCARS.ColorRed,
	}
	buttons[modeCount + 3] = utilButtonData

	local height = table.maxn(buttons) * 35 + 80
	local success2, menuWindow = Star_Trek.LCARS:CreateWindow(
		"button_list",
		pos,
		ang,
		24,
		width,
		height,
		function(windowData, interfaceData, buttonId)
			if buttonId > modeCount then
				windowData:Close()
			else
				local buttonName = windowData.Buttons[buttonId].Name
				windowData:SetSelected({
					[buttonName] = true
				})

				actionWindow:SetButtons(self:GetModeButtons(buttonId))
				actionWindow:Update()

				return true
			end
		end,
		buttons,
		"MODES"
	)
	if not success2 then
		return false, menuWindow
	end

	local buttonName = menuWindow.Buttons[1].Name
	menuWindow:SetSelected({
		[buttonName] = true
	})

	return true, menuWindow, actionWindow
end

-- Generates the map view.
function SELF:CreateMapWindow(pos, ang, width, height, deck)
	local success, mapWindow = Star_Trek.LCARS:CreateWindow("section_map", pos, ang, nil, width, height, function(windowData, interfaceData, buttonId)
		-- No Interactivity here yet.
	end, deck)
	if not success then
		return false, mapWindow
	end

	return true, mapWindow
end

return securityUtil
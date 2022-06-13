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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--    LCARS Bridge Security | Util   --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
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

local classBlacklist = {
	"spotlight_end",
	"beam",
	"force_field"
}

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
		function(windowData, interfaceData, ply, buttonId)
			local buttonName = windowData.Buttons[buttonId].Name
			local sectionWindow = interfaceData.Windows[2]
			local mapWindow = interfaceData.Windows[3]
			local sectionIds = {}
			for _, buttonData in pairs(sectionWindow.Buttons) do
				if buttonData.Selected then
					table.insert(sectionIds, buttonData.Data)
				end
			end

			local deck = sectionWindow.Selected

			-------- Scan --------
			if buttonName == "Scan Lifeforms" then
				local entities = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if table.HasValue(classBlacklist, ent:GetClass()) then return true end

					if not hook.Run("Star_Trek.Util.IsLifeForm", ent) then return true end
				end, false, true)

				mapWindow:SetObjects(entities)
				mapWindow:Update()

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "")
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Lifeform scan started!")

				for _, ent in pairs(entities) do
					local sectionName = Star_Trek.Sections:GetSectionName(deck, ent.DetectedInSection)

					Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Lifeform found in " .. sectionName)
				end

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Total: " .. table.Count(entities) .. " Lifeforms found.")

				return true
			elseif buttonName == "Scan Objects" then
				local entities = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if table.HasValue(classBlacklist, ent:GetClass()) then return true end

					if hook.Run("Star_Trek.Util.IsLifeForm", ent) then return true end
				end, false, true)

				mapWindow:SetObjects(entities)
				mapWindow:Update()

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "")
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Non-Lifeform scan started!")

				for _, ent in pairs(entities) do
					local sectionName = Star_Trek.Sections:GetSectionName(deck, ent.DetectedInSection)

					Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Non-Lifeform found in " .. sectionName)
				end
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Total: " .. table.Count(entities) .. " Non-Lifeforms found.")

				return true
			elseif buttonName == "Scan Weapons" then

				return true
			elseif buttonName == "Scan All" then
				local entities = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if table.HasValue(classBlacklist, ent:GetClass()) then return true end
				end, false, true)

				mapWindow:SetObjects(entities)
				mapWindow:Update()

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "")
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Internal scan started!")

				local lifeforms = 0
				local objects = 0
				for _, ent in pairs(entities) do
					local sectionName = Star_Trek.Sections:GetSectionName(deck, ent.DetectedInSection)

					if hook.Run("Star_Trek.Util.IsLifeForm", ent) then
						Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Lifeform found in " .. sectionName)
						lifeforms = lifeforms + 1
					else
						Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Non-Lifeform found in " .. sectionName)
						objects = objects + 1
					end
				end
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Total: " .. lifeforms .. " Lifeforms found.")
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Total: " .. objects .. " Non-Lifeforms found.")
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Total: " .. lifeforms + objects .. " Objects found.")

				return true

			-------- Lockdown --------
			elseif buttonName == "Lock Doors" then
				local doors = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if ent.LCARSKeyData and ent.LCARSKeyData["lcars_ignore_security"] then
						return true
					end

					if ent.JeffriesDoor then
						return true
					end

					if Star_Trek.Doors.Doors[ent] then
						return
					end

					return true
				end, true)

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "")

				for _, door in pairs(doors) do
					door:Fire("AddOutput", "lcars_locked 1")

					local sectionName = Star_Trek.Sections:GetSectionName(deck, door.DetectedInSection)
					Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Door #" .. door:MapCreationID() .. " in " .. sectionName .. " has been locked.")
				end

				mapWindow:SetObjects(doors)
				mapWindow:Update()

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Total: " .. table.Count(doors) .. " Doors locked.")

				return true
			elseif buttonName == "Unlock Doors" then
				local doors = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if ent.LCARSKeyData and ent.LCARSKeyData["lcars_ignore_security"] then
						return true
					end

					if ent.JeffriesDoor then
						return true
					end

					if Star_Trek.Doors.Doors[ent] then
						return
					end

					return true
				end, true)

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "")

				for _, door in pairs(doors) do
					door:Fire("AddOutput", "lcars_locked 0")

					local sectionName = Star_Trek.Sections:GetSectionName(deck, door.DetectedInSection)
					Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Door #" .. door:MapCreationID() .. " in " .. sectionName .. " has been unlocked.")
				end

				mapWindow:SetObjects(doors)
				mapWindow:Update()

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Total: " .. table.Count(doors) .. " Doors unlocked.")

				return true
			elseif buttonName == "Enable Forcefields" then
				local success1, forceFieldPositions = Star_Trek.Security:EnableForceFieldsInSections(deck, sectionIds)
				if not success1 then
					return
				end

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "")

				local objects = {}
				for _, posData in pairs(forceFieldPositions) do
					local objectTable = {
						Pos = posData.Pos,
						Color = Star_Trek.LCARS.ColorBlue,
					}

					table.insert(objects, objectTable)

					local sectionName = Star_Trek.Sections:GetSectionName(deck, posData.DetectedInSection)
					Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Force Field in " .. sectionName .. " has been enabled.")
				end

				mapWindow:SetObjects(objects)
				mapWindow:Update()

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Total: " .. table.Count(forceFieldPositions) .. " Forcefields enabled.")

				return true
			elseif buttonName == "Disable Forcefields" then
				local success1, forceFieldPositions = Star_Trek.Security:DisableForceFieldsInSections(deck, sectionIds)
				if not success1 then
					return
				end

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "")

				local objects = {}
				for _, posData in pairs(forceFieldPositions) do
					local objectTable = {
						Pos = posData.Pos,
						Color = Star_Trek.LCARS.ColorBlue,
					}

					table.insert(objects, objectTable)

					local sectionName = Star_Trek.Sections:GetSectionName(deck, posData.DetectedInSection)
					Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Force Field in " .. sectionName .. " has been disabled.")
				end

				mapWindow:SetObjects(objects)
				mapWindow:Update()

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Total: " .. table.Count(forceFieldPositions) .. " Forcefields disabled.")

				return true
			elseif buttonName == "Unlock All" then
				local doors = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if ent.LCARSKeyData and ent.LCARSKeyData["lcars_ignore_security"] then
						return true
					end

					if ent.JeffriesDoor then
						return true
					end

					if Star_Trek.Doors.Doors[ent] then
						return
					end

					return true
				end, true)

				local success1, forceFieldPositions = Star_Trek.Security:DisableForceFieldsInSections(deck, sectionIds)
				if not success1 then
					return
				end

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "")

				for _, door in pairs(doors) do
					door:Fire("AddOutput", "lcars_locked 0")

					local sectionName = Star_Trek.Sections:GetSectionName(deck, door.DetectedInSection)
					Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Door #" .. door:MapCreationID() .. " in " .. sectionName .. " has been unlocked.")
				end

				mapWindow:SetObjects(doors)
				for _, posData in pairs(forceFieldPositions) do
					local objectTable = {
						Pos = posData.Pos,
						Color = Star_Trek.LCARS.ColorBlue,
					}

					table.insert(mapWindow.Objects, objectTable)

					local sectionName = Star_Trek.Sections:GetSectionName(deck, posData.DetectedInSection)
					Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Force Field in " .. sectionName .. " has been disabled.")
				end

				mapWindow:Update()

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Total: " .. table.Count(doors) .. " Doors unlocked.")
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Total: " .. table.Count(forceFieldPositions) .. " Forcefields disabled.")
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Total: " .. table.Count(forceFieldPositions) + table.Count(doors) .. " Security Measures disabled.")

				return true

			-------- Alerts --------
			elseif buttonName == "Red Alert" then
				Star_Trek.Alert:Enable("red")

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "")
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "RED ALERT!")

				return true
			elseif buttonName == "Yellow Alert" then
				Star_Trek.Alert:Enable("yellow")

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "")
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "YELLOW ALERT!")

				return true
			elseif buttonName == "Intruder Alert" then
				Star_Trek.Alert:Enable("intruder")

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "")
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "INTRUDER ALERT!")

				return true
			elseif buttonName == "Blue Alert" then
				Star_Trek.Alert:Enable("blue")

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "")
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "BLUE ALERT!")

				return true
			elseif buttonName == "Disable Alert" then
				Star_Trek.Alert:Disable()

				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "")
				Star_Trek.Logs:AddEntry(interfaceData.Ent, ply, "Alerts Disabled!")

				return true
			end
		end,
		buttons,
		"Actions",
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
		function(windowData, interfaceData, ply, buttonId)
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
	local success, mapWindow = Star_Trek.LCARS:CreateWindow("section_map", pos, ang, nil, width, height, function(windowData, interfaceData, ply, buttonId)
		-- No Interactivity here yet.
	end, deck)
	if not success then
		return false, mapWindow
	end

	return true, mapWindow
end

return securityUtil
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

function SELF:ActionButtonPressed(windowData, ply, buttonId, buttonData)
	local buttonName = buttonData.Name
	local sectionWindow = self.Windows[2]
	local mapWindow = self.Windows[3]

	local deck = sectionWindow.Selected
	local sectionIds = {}
	for _, sectionButtonData in pairs(sectionWindow.Buttons) do
		if sectionButtonData.Selected then
			table.insert(sectionIds, sectionButtonData.Data)
		end
	end

	if windowData.Mode == MODE_SCAN then
		Star_Trek.Logs:AddEntry(self.Ent, ply, "")
		Star_Trek.Logs:AddEntry(self.Ent, ply, "Starting internal scan!")

		local scanLife
		if buttonName == "Scan Lifeforms"
		or buttonName == "Scan All" then
			Star_Trek.Logs:AddEntry(self.Ent, ply, "Scanning for Lifeforms...")

			scanLife = true
		end

		local scanObjects
		if buttonName == "Scan Objects"
		or buttonName == "Scan All" then
			Star_Trek.Logs:AddEntry(self.Ent, ply, "Scanning for Objects...")

			scanObjects = true
		end

		local scanWeapons
		if buttonName == "Scan Weapons"
		or buttonName == "Scan All" then
			Star_Trek.Logs:AddEntry(self.Ent, ply, "Scanning for Weapons...")

			scanWeapons = true
		end

		Star_Trek.Logs:AddEntry(self.Ent, ply, "")

		local success2, objects = Star_Trek.Sensors:ScanInternal(deck, sectionIds, scanLife, scanObjects, scanWeapons)
		if not success2 then
			Star_Trek.Logs:AddEntry(self.Ent, ply, objects)
			self.Ent:EmitSound("star_trek.lcars_error")

			return
		end

		mapWindow:SetObjects(objects)
		mapWindow:Update()

		for _, object in pairs(objects) do
			local scanData = object.ScanData
			Star_Trek.Logs:AddEntry(self.Ent, ply, scanData.Name .. " found in " .. object.SectionName)

			-- Print all the weapons the player has equiped in the log
			if istable(scanData.Weapons) then
				Star_Trek.Logs:AddEntry(self.Ent, ply, scanData.Name .. "'s equipment: ")

				local finalStringNormal = ""
				for i, weapon in ipairs(scanData.Weapons) do
					if i == #scanData.Weapons then
						finalStringNormal = finalStringNormal .. weapon.Name
					else
						finalStringNormal = finalStringNormal .. weapon.Name .. ", "
					end
				end
				Star_Trek.Logs:AddEntry(self.Ent, ply, finalStringNormal)
				Star_Trek.Logs:AddEntry(self.Ent, ply, "")
			end
		end

		Star_Trek.Logs:AddEntry(self.Ent, ply, "Total Count: " .. table.Count(objects))

		return true
	elseif windowData.Mode == MODE_BLOCK then
		Star_Trek.Logs:AddEntry(self.Ent, ply, "")

		local objects = {}

		if buttonName == "Lock Doors"
		or buttonName == "Unlock Doors"
		or buttonName == "Unlock All" then
			local doors = Star_Trek.Sections:GetInSections(deck, sectionIds, function(object)
				local ent = object.Entity
				if not Star_Trek.Doors.Doors[ent] then
					return true
				end

				if ent.JeffriesDoor then
					return true
				end

				if ent.LCARSKeyData and ent.LCARSKeyData["lcars_ignore_security"] then
					return true
				end
			end, true)

			for _, object in pairs(doors) do
				local ent = object.Entity
				local sectionName = Star_Trek.Sections:GetSectionName(ent.Deck, ent.SectionId)

				table.insert(objects, ent)

				if buttonName == "Lock Doors" then
					ent:Fire("AddOutput", "lcars_locked 1")
					Star_Trek.Logs:AddEntry(self.Ent, ply, "Door #" .. ent:MapCreationID() .. " in " .. sectionName .. " has been locked.")
				else
					ent:Fire("AddOutput", "lcars_locked 0")
					Star_Trek.Logs:AddEntry(self.Ent, ply, "Door #" .. ent:MapCreationID() .. " in " .. sectionName .. " has been unlocked.")
				end
			end

			if buttonName == "Lock Doors" then
				Star_Trek.Logs:AddEntry(self.Ent, ply, "Total: " .. table.Count(doors) .. " doors locked!")
			else
				Star_Trek.Logs:AddEntry(self.Ent, ply, "Total: " .. table.Count(doors) .. " doors unlocked!")
			end
		end

		if buttonName == "Enable Forcefields"
		or buttonName == "Disable Forcefields"
		or buttonName == "Unlock All" then
			if buttonName == "Enable Forcefields" then
				local success2, forceFieldPositions = Star_Trek.ForceFields:EnableForceFieldsInSections(deck, sectionIds)
				if not success2 then
					return
				end

				for _, posData in pairs(forceFieldPositions) do
					local sectionName = Star_Trek.Sections:GetSectionName(posData.Deck, posData.SectionId)
					Star_Trek.Logs:AddEntry(self.Ent, ply, "Force Field in " .. sectionName .. " has been enabled.")

					table.insert(objects, {Pos = posData.Pos})
				end

				Star_Trek.Logs:AddEntry(self.Ent, ply, "Total: " .. table.Count(forceFieldPositions) .. " forcefields enabled.")
			else
				local success2, forceFieldPositions = Star_Trek.ForceFields:DisableForceFieldsInSections(deck, sectionIds)
				if not success2 then
					return
				end

				for _, posData in pairs(forceFieldPositions) do
					local sectionName = Star_Trek.Sections:GetSectionName(posData.Deck, posData.SectionId)
					Star_Trek.Logs:AddEntry(self.Ent, ply, "Force Field in " .. sectionName .. " has been disabled.")

					table.insert(objects, {Pos = posData.Pos})
				end

				Star_Trek.Logs:AddEntry(self.Ent, ply, "Total: " .. table.Count(forceFieldPositions) .. " forcefields disabled.")
			end
		end

		mapWindow:SetObjects(objects)
		mapWindow:Update()

		return true
	elseif windowData.Mode == MODE_ALERT then
		if buttonName == "Red Alert" then
			Star_Trek.Alert:Enable("red")

			Star_Trek.Logs:AddEntry(self.Ent, ply, "")
			Star_Trek.Logs:AddEntry(self.Ent, ply, "RED ALERT!")
		elseif buttonName == "Yellow Alert" then
			Star_Trek.Alert:Enable("yellow")

			Star_Trek.Logs:AddEntry(self.Ent, ply, "")
			Star_Trek.Logs:AddEntry(self.Ent, ply, "YELLOW ALERT!")
		elseif buttonName == "Intruder Alert" then
			Star_Trek.Alert:Enable("intruder")

			Star_Trek.Logs:AddEntry(self.Ent, ply, "")
			Star_Trek.Logs:AddEntry(self.Ent, ply, "INTRUDER ALERT!")
		elseif buttonName == "Blue Alert" then
			Star_Trek.Alert:Enable("blue")

			Star_Trek.Logs:AddEntry(self.Ent, ply, "")
			Star_Trek.Logs:AddEntry(self.Ent, ply, "BLUE ALERT!")
		elseif buttonName == "Disable Alert" then
			Star_Trek.Alert:Disable()

			Star_Trek.Logs:AddEntry(self.Ent, ply, "")
			Star_Trek.Logs:AddEntry(self.Ent, ply, "Alert Disabled!")
		end

		return true
	end
end

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
		function(windowData, interfaceData, ply, buttonId, buttonData)
			return self:ActionButtonPressed(windowData, ply, buttonId, buttonData)
		end,
		buttons,
		"Actions",
		nil,
		flip
	)
	if not success then
		return false, actionWindow
	end

	actionWindow.Mode = mode

	return true, actionWindow
end

function SELF:CreateMenuWindow(pos, ang, width, actionPos, actionAng, actionWidth, flipAction)
	local success, actionWindow = self:CreateActionWindow(actionPos, actionAng, actionWidth, flipAction, 1)
	if not success then
		return false, actionWindow
	end

	local modes = self.Modes or {
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
	buttons[6] = utilButtonData

	local height = table.maxn(buttons) * 35 + 80
	local success2, menuWindow = Star_Trek.LCARS:CreateWindow(
		"button_list",
		pos,
		ang,
		24,
		width,
		height,
		function(windowData, interfaceData, ply, buttonId, buttonData)
			if buttonId > modeCount then
				windowData:Close()
			else
				local buttonName = buttonData.Name
				windowData:SetSelected({
					[buttonName] = true
				})

				actionWindow:SetButtons(self:GetModeButtons(buttonId))
				actionWindow.Mode = buttonId
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
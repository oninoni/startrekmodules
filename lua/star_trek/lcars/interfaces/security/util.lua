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
--       LCARS Security | Util       --
---------------------------------------

local securityUtil = {}

local MODE_SCAN = 1
local MODE_BLOCK = 2
local MODE_ALERT = 3

function securityUtil.GetModeButtons(mode)
	mode = mode or MODE_SCAN

	local actions = {}
	local actionColors = {}
	if mode == MODE_SCAN then
		actions = {
			[1] = "Scan Lifeforms",
			[2] = "Scan Objects",
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

function securityUtil.CreateActionWindow(mode)
	local buttons = securityUtil.GetModeButtons(mode)
	local height = table.maxn(buttons) * 35 + 80
	local success, actionWindow = Star_Trek.LCARS:CreateWindow(
		"button_list",
		Vector(22, -34, 8.2),
		Angle(0, 0, -90),
		24,
		500,
		height,
		function(windowData, interfaceData, buttonId)
			local buttonName = windowData.Buttons[buttonId].Name
			local sectionWindow = interfaceData.Windows[2]
			local mapWindow = interfaceData.Windows[3]
			local sectionIds = {}
			for _, buttonData in pairs(sectionWindow.Buttons) do
				if buttonData.Selected then
					table.insert(sectionIds, buttonData.Data.Id)
				end
			end

			local deck = sectionWindow.Selected

-------- Scan --------

			if buttonName == "Scan Lifeforms" then
				local entities = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if not hook.Run("Star_Trek.Util.IsLifeForm", ent) then return true end
				end)

				mapWindow:SetObjects(entities)
				mapWindow:Update()

				return true
			elseif buttonName == "Scan Objects" then
				local entities = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if hook.Run("Star_Trek.Util.IsLifeForm", ent) then return true end
				end)

				mapWindow:SetObjects(entities)
				mapWindow:Update()

				return true
			elseif buttonName == "Scan All" then
				local entities = Star_Trek.Sections:GetInSections(deck, sectionIds)

				mapWindow:SetObjects(entities)
				mapWindow:Update()

				return true

-------- Lockdown --------

			elseif buttonName == "Lock Doors" then
				local doors = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if ent:GetClass() == "prop_dynamic" and table.HasValue(Star_Trek.Doors.Models, ent:GetModel()) then
						return
					end

					return true
				end, true)

				for _, door in pairs(doors) do
					door:Fire("AddOutput", "lcars_locked 1")
				end

				mapWindow:SetObjects(doors)
				mapWindow:Update()

				return true
			elseif buttonName == "Unlock Doors" then
				local doors = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if ent:GetClass() == "prop_dynamic" and table.HasValue(Star_Trek.Doors.Models, ent:GetModel()) then
						return
					end

					return true
				end, true)

				for _, door in pairs(doors) do
					door:Fire("AddOutput", "lcars_locked 0")
				end

				mapWindow:SetObjects(doors)
				mapWindow:Update()

				return true
			elseif buttonName == "Enable Forcefields" then
				-- TODO: Add Forcefields

				return true
			elseif buttonName == "Disable Forcefields" then
				-- TODO: Add Forcefields

				return true
			elseif buttonName == "Unlock All" then
				local doors = Star_Trek.Sections:GetInSections(deck, sectionIds, function(objects, ent)
					if ent:GetClass() == "prop_dynamic" and table.HasValue(Star_Trek.Doors.Models, ent:GetModel()) then
						return
					end

					return true
				end, true)

				for _, door in pairs(doors) do
					door:Fire("AddOutput", "lcars_locked 0")
				end
				-- TODO: Add Forcefields

				mapWindow:SetObjects(doors)
				mapWindow:Update()

				return true

-------- Alerts --------

			-- TODO: Add When alerts exist.
			elseif buttonName == "Red Alert" then

				return true
			elseif buttonName == "Yellow Alert" then

				return true
			elseif buttonName == "Intruder Alert" then

				return true
			elseif buttonName == "Disable Alert" then

				return true
			end
		end,
		buttons,
		"Stuff",
		nil,
		true
	)
	if not success then
		return false, actionWindow
	end

	return true, actionWindow
end

function securityUtil.CreateMenuWindow()
	local success, actionWindow = securityUtil.CreateActionWindow(1)
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
		Vector(-22, -34, 8.2),
		Angle(0, 0, -90),
		24,
		500,
		height,
		function(windowData, interfaceData, buttonId)
			if buttonId > modeCount then
				windowData:Close()
			else
				local buttonName = windowData.Buttons[buttonId].Name
				windowData:SetSelected({
					[buttonName] = true
				})

				actionWindow:SetButtons(securityUtil.GetModeButtons(buttonId))
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
function securityUtil.CreateMapWindow(deck)
	local success, mapWindow = Star_Trek.LCARS:CreateWindow("section_map", Vector(12.5, -2, -2), Angle(0, 0, 0), nil, 1100, 680, function(windowData, interfaceData, buttonId)
		-- No Interactivity here yet.
	end, deck)
	if not success then
		return false, mapWindow
	end

	return true, mapWindow
end

return securityUtil
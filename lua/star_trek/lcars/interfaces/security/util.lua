local securityUtil = {}

local MODE_SCAN = 1
local MODE_BLOCK = 2
local MODE_ALERT = 3

function securityUtil.CreateActionWindow(mode)
	mode = mode or MODE_SCAN
	
	local actions = {}
	if mode == MODE_SCAN then
		actions = {
			[1] = "Scan Lifeforms",
			[2] = "Scan Objects",
			[6] = "Scan All",
		}
	elseif mode == MODE_BLOCK then
		actions = {
			[1] = "Lock Doors",
			[2] = "Unlock Doors",
			[3] = "Enable Forcefields",
			[4] = "Disable Forcefields",
			[6] = "Unlock All",
		}
	elseif mode == MODE_ALERT then
		actions = {
			[1] = "Red Alert",
			[2] = "Yellow Alert",
			[6] = "Disable Alert",
		}
	end

	local buttons = {}
	for i, name in pairs(actions) do
		local color = Star_Trek.LCARS.ColorBlue
		if i % 2 == 0 then
			color = Star_Trek.LCARS.ColorLightBlue
		end
		
		buttons[i] = {
			Name = name,
			Color = color,
		}
	end

	local height = table.maxn(buttons) * 35 + 80
	local success, actionWindow = Star_Trek.LCARS:CreateWindow(
		"button_list",
		Vector(22, -34, 8.2),
		Angle(0, 0, -90),
		24,
		500,
		height,
		function(windowData, interfaceData, ent, buttonId)
			
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
		function(windowData, interfaceData, ent, buttonId)
			if buttonId == modeCount + 2 then
				ent:EmitSound("star_trek.lcars_close")
				Star_Trek.LCARS:CloseInterface(ent)
			else
				print("---")
				PrintTable(windowData:GetSelected())
				print("...")
				windowData:SetSelected({
					[buttonId] = true
				})
				PrintTable(windowData:GetSelected())
				
				Star_Trek.LCARS:UpdateWindow(ent, windowData.WindowId, windowData)
			end
		end,
		buttons,
		"MODES"
	)
	if not success2 then
		return false, menuWindow
	end

	return true, menuWindow, actionWindow
end

-- Generates the map view.
function securityUtil.CreateMapWindow(deck)
	local success, mapWindow = Star_Trek.LCARS:CreateWindow("section_map", Vector(12.5, -2, -2), Angle(0, 0, 0), nil, 1100, 680, function(windowData, interfaceData, ent, buttonId)
		-- No Interactivity here yet.
	end, deck)
	if not success then
		return false, mapWindow
	end

	return true, mapWindow
end

return securityUtil
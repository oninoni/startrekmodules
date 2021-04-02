local securityUtil = include("util.lua")

function Star_Trek.LCARS:OpenSecurityMenu()
	local success, interfaceEnt = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
	if not success then
		Star_Trek:Message(interfaceEnt)
		return
	end

	if istable(self.ActiveInterfaces[interfaceEnt]) then
		return
	end

	local modes = {
		"Internal Scanners",
		"Security Measures",
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
	buttons[modeCount + 2] = utilButtonData

	local height = table.maxn(buttons) * 35 + 80
	local success2, menuWindow = Star_Trek.LCARS:CreateWindow(
		"button_list",
		Vector(-22, -34, 8.2),
		Angle(0, 0, -90),
		18,
		400,
		height,
		function(windowData, interfaceData, ent, buttonId)
			if buttonId == modeCount + 2 then
				ent:EmitSound("star_trek.lcars_close")
				Star_Trek.LCARS:CloseInterface(ent)
			else
				-- TODO: Mode Selection
			end
		end,
		buttons,
		"MODES"
	)
	if not success2 then
		Star_Trek:Message(menuWindow)
		return
	end

	local success3, mapWindow = securityUtil.CreateMapWindow(1)
	if not success3 then
		Star_Trek:Message(mapWindow)
		return
	end

	local success4, sectionWindow = Star_Trek.LCARS:CreateWindow(
		"category_list",
		Vector(-28, -5, -2),
		Angle(0, 0, 0),
		nil,
		500,
		700,
		function(windowData, interfaceData, ent, categoryId, buttonId)
			if isnumber(buttonId) then
				local windowFunctions = Star_Trek.LCARS.Windows[mapWindow.WindowType]
				if not istable(windowFunctions) then
					Star_Trek:Message("Invalid Map Window Type!")
					return
				end

				local buttonData = windowData.Categories[categoryId].Buttons[buttonId]
				local sectionId = buttonData.Data.Id

				local selected = windowFunctions.GetSelected(mapWindow)
				selected[sectionId] = buttonData.Selected

				windowFunctions.SetSelected(mapWindow, selected)
				
				Star_Trek.LCARS:UpdateWindow(ent, mapWindow.WindowId, mapWindow)
			else
				local updateSuccess, newMapWindow = securityUtil.CreateMapWindow(categoryId)
				if not updateSuccess then
					Star_Trek:Message(newMapWindow)
					return
				end

				Star_Trek.LCARS:UpdateWindow(ent, mapWindow.WindowId, newMapWindow)
				newMapWindow.WindowId = mapWindow.WindowId
				mapWindow = newMapWindow
			end
		end,
		Star_Trek.LCARS:GetSectionCategories(),
		"SECTIONS",
		"SECTNS",
		false,
		true
	)
	if not success4 then
		Star_Trek:Message(menuWindow)
		return
	end

	local windows = Star_Trek.LCARS:CombineWindows(
		menuWindow,
		sectionWindow,
		mapWindow
	)

	local success5, error = self:OpenInterface(interfaceEnt, windows)
	if not success5 then
		Star_Trek:Message(error)
		return
	end
end
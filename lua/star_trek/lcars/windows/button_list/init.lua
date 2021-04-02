function WINDOW.OnCreate(windowData, buttons, title, titleShort, hFlip, toggle)
	windowData.Buttons = {}
	windowData.Title = title or ""
	windowData.TitleShort = titleShort or windowData.Title
	windowData.HFlip = hFlip or false
	windowData.Toggle = toggle or false

	if not istable(buttons) then
		return false
	end

	for i, button in pairs(buttons) do
		if not istable(button) then continue end

		local buttonData = {
			Name = button.Name or "MISSING",
			Disabled = button.Disabled or false,
			Data = button.Data,
		}

		if IsColor(button.Color) then
			buttonData.Color = button.Color
		else
			if windowData.Toggle then
				if i % 2 == 0 then
					buttonData.Color = Star_Trek.LCARS.ColorLightBlue
				else
					buttonData.Color = Star_Trek.LCARS.ColorBlue
				end
			else
				buttonData.Color = table.Random(Star_Trek.LCARS.Colors)
			end
		end

		buttonData.RandomS = Star_Trek.LCARS:GetSmallNumber(button.RandomS)
		buttonData.RandomL = Star_Trek.LCARS:GetLargeNumber(button.RandomL)

		windowData.Buttons[i] = buttonData
	end

	return windowData
end

function WINDOW.GetSelected(windowData)
	local data = {}
	for _, buttonData in pairs(windowData.Buttons) do
		data[buttonData.Name] = buttonData.Selected
	end

	return data
end

function WINDOW.SetSelected(windowData, data)
	for name, selected in pairs(data) do
		for _, buttonData in pairs(windowData.Buttons) do
			if buttonData.Name == name then
				buttonData.Selected = selected
				break
			end
		end
	end
end

function WINDOW.OnPress(windowData, interfaceData, ent, buttonId, callback)
	local shouldUpdate = false

	if windowData.Toggle then
		local buttonData = windowData.Buttons[buttonId]
		if istable(buttonData) then
			buttonData.Selected = not (buttonData.Selected or false)
			shouldUpdate = true
		end
	end

	if isfunction(callback) then
		local updated = callback(windowData, interfaceData, ent, buttonId)
		if updated then
			shouldUpdate = true
		end
	end

	if Star_Trek.LCARS.ActiveInterfaces[ent] and not Star_Trek.LCARS.ActiveInterfaces[ent].Closing then
		ent:EmitSound("star_trek.lcars_beep")
	end

	return shouldUpdate
end
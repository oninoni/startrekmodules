function WINDOW:OnCreate(buttons, title, titleShort, hFlip, toggle)
	self.Buttons = {}
	self.Title = title or ""
	self.TitleShort = titleShort or self.Title
	self.HFlip = hFlip or false
	self.Toggle = toggle or false

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
			if self.Toggle then
				if i % 2 == 0 then
					buttonData.Color = Star_Trek.LCARS.ColorLightBlue
				else
					buttonData.Color = Star_Trek.LCARS.ColorBlue
				end
			else
				buttonData.Color = table.Random(Star_Trek.LCARS.Colors)
			end
		end

		buttonData.RandomS = button.RandomS
		buttonData.RandomL = button.RandomL

		self.Buttons[i] = buttonData
	end

	return self
end

function WINDOW:GetSelected()
	local data = {}
	for _, buttonData in pairs(self.Buttons) do
		data[buttonData.Name] = buttonData.Selected
	end

	return data
end

function WINDOW:SetSelected(data)
	for name, selected in pairs(data) do
		for _, buttonData in pairs(self.Buttons) do
			if buttonData.Name == name then
				buttonData.Selected = selected
				break
			end
		end
	end
end

function WINDOW:OnPress(interfaceData, ent, buttonId, callback)
	local shouldUpdate = false

	if self.Toggle then
		local buttonData = self.Buttons[buttonId]
		if istable(buttonData) then
			buttonData.Selected = not (buttonData.Selected or false)
			shouldUpdate = true
		end
	end

	if isfunction(callback) then
		local updated = callback(self, interfaceData, ent, buttonId)
		if updated then
			shouldUpdate = true
		end
	end

	if Star_Trek.LCARS.ActiveInterfaces[ent] and not Star_Trek.LCARS.ActiveInterfaces[ent].Closing then
		ent:EmitSound("star_trek.lcars_beep")
	end

	return shouldUpdate
end
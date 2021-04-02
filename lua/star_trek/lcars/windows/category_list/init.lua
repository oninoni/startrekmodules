function WINDOW:OnCreate(categories, title, titleShort, hFlip, toggle)
	self.Categories = {}
	self.Title = title or ""
	self.TitleShort = titleShort or self.Title
	self.HFlip = hFlip or false
	self.Toggle = toggle

	if not istable(categories) then
		return false
	end

	for i, category in pairs(categories) do
		if not istable(category) or not istable(category.Buttons) then continue end

		local categoryData = {
			Name = category.Name or "MISSING",
			Disabled = category.Disabled or false,
			Data = category.Data,
			Buttons = {}
		}

		if not self.Selected then
			self.Selected = i
		end

		if IsColor(category.Color) then
			categoryData.Color = category.Color
		else
			if i % 2 == 0 then
				categoryData.Color = Star_Trek.LCARS.ColorLightBlue
			else
				categoryData.Color = Star_Trek.LCARS.ColorBlue
			end
		end

		for j, button in pairs(category.Buttons) do
			local buttonData = {
				Name = button.Name or "MISSING",
				Disabled = button.Disabled or false,
				Data = button.Data,
			}

			if IsColor(button.Color) then
				buttonData.Color = button.Color
			else
				if self.Toggle then
					if j % 2 == 0 then
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

			table.insert(categoryData.Buttons, buttonData)
		end

		categoryData.Id = table.insert(self.Categories, categoryData)
	end

	return self
end

function WINDOW:GetSelected()
	local data = {
		Buttons = {}
	}

	local categoryData = self.Categories[self.Selected]
	if istable(categoryData) then
		data.Selected = categoryData.Name
		for _, buttonData in pairs(categoryData.Buttons) do
			data.Buttons[buttonData.Name] = buttonData.Selected
		end
	end

	return data
end

function WINDOW:SetSelected(data)
	for i, categoryData in pairs(self.Categories) do
		if categoryData.Name == data.Selected then
			self.Selected = i

			for name, selected in pairs(data.Buttons) do
				for _, buttonData in pairs(categoryData.Buttons) do
					if buttonData.Name == name then
						buttonData.Selected = selected
						break
					end
				end
			end

			break
		end
	end
end

function WINDOW:OnPress(interfaceData, ent, buttonId, callback)
	local categoryId = self.Selected
	local categoryCount = table.Count(self.Categories)
	local categoryData = self.Categories[categoryId]

	local shouldUpdate = false

	if buttonId <= categoryCount then
		-- Category Selection
		if buttonId ~= categoryId then
			local newData = self.Categories[buttonId]
			if istable(newData) and not newData.Disabled then
				self.Selected = buttonId

				for _, buttonData in pairs(categoryData.Buttons) do
					buttonData.Selected = nil
				end

				shouldUpdate = true

				if isfunction(callback) then
					callback(self, interfaceData, ent, buttonId, nil)
				end

				if Star_Trek.LCARS.ActiveInterfaces[ent] and not Star_Trek.LCARS.ActiveInterfaces[ent].Closing then
					ent:EmitSound("star_trek.lcars_beep2")
				end
			end
		end
	else
		-- Buttons
		buttonId = buttonId - categoryCount

		if self.Toggle then
			local buttonData = categoryData.Buttons[buttonId]
			if istable(buttonData) then
				buttonData.Selected = not (buttonData.Selected or false)
				shouldUpdate = true
			end
		end

		if isfunction(callback) then
			local updated = callback(self, interfaceData, ent, categoryId, buttonId)
			if updated then
				shouldUpdate = true
			end
		end

		if Star_Trek.LCARS.ActiveInterfaces[ent] and not Star_Trek.LCARS.ActiveInterfaces[ent].Closing then
			ent:EmitSound("star_trek.lcars_beep")
		end
	end

	return shouldUpdate
end
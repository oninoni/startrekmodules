local function getCategoryRow(self, categories)
	local rowData = {
		Categories = {}
	}

	if #categories == 1 then
		rowData.Width = self.WWidth -58
		rowData.N = 1

		table.insert(rowData.Categories, categories[1])
	elseif #categories == 2 then
		rowData.Width = (self.WWidth -58) / 2
		rowData.N = 2

		table.insert(rowData.Categories, categories[1])
		table.insert(rowData.Categories, categories[2])
	elseif #categories == 3 or #categories == 4 then
		rowData.Width = (self.WWidth -58) / 4
		rowData.N = 4

		table.insert(rowData.Categories, categories[1])
		table.insert(rowData.Categories, categories[2])
		table.insert(rowData.Categories, categories[3])
		if #categories == 4 then
			table.insert(rowData.Categories, categories[4])
		else
			table.insert(rowData.Categories, {
				Disabled = true,
				Name = "",
				Color = Star_Trek.LCARS.ColorGrey,
			})
		end
	end

	return rowData
end

local BUTTON_HEIGHT = 32

function WINDOW.OnCreate(self, windowData)
	self.Title = windowData.Title
	self.TitleShort = windowData.TitleShort
	self.HFlip = windowData.HFlip

	self.Selected = windowData.Selected
	self.Categories = windowData.Categories

	self.MaxN = table.Count(self.Categories)

	self.CategoryStart = -self.HD2 + 79
	self.CategoryHeight = math.max(2, math.ceil(self.MaxN / 4)) * 35 + 50

	self.ButtonsStart = -self.HD2 + self.CategoryHeight + 79
	self.ButtonsHeight = self.HD2 - self.ButtonsStart

	self.ButtonsTopAlpha = self.ButtonsStart
	self.ButtonsBotAlpha = self.HD2 - 20

	self.CategoryRows = {}
	local categories = table.Copy(self.Categories)
	while true do
		if #categories > 4 then
			local subCategories = {
				table.remove(categories, 1),
				table.remove(categories, 1),
				table.remove(categories, 1),
				table.remove(categories, 1),
			}

			table.insert(self.CategoryRows, getCategoryRow(self, subCategories))
		else
			table.insert(self.CategoryRows, getCategoryRow(self, categories))

			break
		end
	end

	self.FrameMaterialData = Star_Trek.LCARS:CreateFrame(
		self.Id,
		self.WWidth,
		self.WHeight,
		self.Title,
		self.TitleShort,
		Star_Trek.LCARS.ColorOrange,
		Star_Trek.LCARS.ColorLightRed,
		Star_Trek.LCARS.ColorBlue,
		self.HFlip,
		self.CategoryHeight,
		Star_Trek.LCARS.ColorLightRed
	)

	for rowId, rowData in pairs(self.CategoryRows) do
		for butId, categoryData in pairs(rowData.Categories) do
			categoryData.MaterialData = Star_Trek.LCARS:CreateButton(
				self.Id .. "_Cat_" .. rowId .. "_" .. butId,
				rowData.Width,
				BUTTON_HEIGHT,
				categoryData.Color,
				Star_Trek.LCARS.ColorYellow,
				categoryData.Name or "[ERROR]",
				butId > 1,
				butId < rowData.N
			)
		end
	end

	for catId, category in pairs(self.Categories) do
		for butId, button in pairs(category.Buttons) do
			button.MaterialData = Star_Trek.LCARS:CreateButton(
				self.Id .. "_But_" .. catId .. "_" .. butId,
				self.WWidth - 64,
				BUTTON_HEIGHT,
				button.Color,
				Star_Trek.LCARS.ColorYellow,
				button.Name or "[ERROR]",
				false,
				false,
				button.RandomL,
				button.RandomS
			)
		end
	end

	return self
end

local function isButtonPressed(x, y, width, height, pos)
	return pos.x >= (x - width/2) and pos.x <= (x + width/2) and pos.y >= (y -1) and pos.y <= (y + height)
end

function WINDOW.OnPress(self, pos, animPos)
	local selected = self.Selected

	if pos.y <= -self.HD2 + self.CategoryHeight + 65 then
		-- Selection
		local x = self.HFlip and -24 or 24
		for rowId, rowData in pairs(self.CategoryRows) do
			for butId, categoryData in pairs(rowData.Categories) do
				local xRow = x + ((butId - 0.5) - rowData.N / 2) * rowData.Width
				local y = self.CategoryStart + (rowId - 1) * 35

				if isButtonPressed(xRow, y, rowData.Width - 3, 32, pos) then
					return categoryData.Id
				end
			end
		end
	else
		-- Button List
		if selected and istable(self.Categories[selected]) then
			local buttons = self.Categories[selected].Buttons
			local n = table.maxn(buttons)

			local offset = Star_Trek.LCARS:GetButtonOffset(self.ButtonsStart, self.ButtonsHeight, n, pos.y)
			for i, button in pairs(buttons) do
				if button.Disabled then continue end

				local y = Star_Trek.LCARS:GetButtonYPos(self.ButtonsHeight, i, n, offset)
				if pos.y >= y - 1 and pos.y <= y + 31 then
					return #self.Categories + i
				end
			end
		end
	end
end

function WINDOW.OnDraw(self, pos, animPos)
	surface.SetDrawColor(255, 255, 255, 255 * animPos)
	local selected = self.Selected
	
	local x = self.HFlip and -24 or 24
	for rowId, rowData in pairs(self.CategoryRows) do
		for butId, categoryData in pairs(rowData.Categories) do
			local xRow = x + ((butId - 0.5) - rowData.N / 2) * rowData.Width
			local y = self.CategoryStart + (rowId - 1) * 35
			
			local state = 1
			if not categoryData.Disabled then
				state = 2
				if selected == categoryData.Id then
					state = state + 1
				end
				if isButtonPressed(xRow, y, rowData.Width - 3, 32, pos) then
					state = state + 3
				end
			end

			Star_Trek.LCARS:RenderButton(xRow, y, categoryData.MaterialData, state)
		end
	end

	if selected and istable(self.Categories[selected]) then
		local buttons = self.Categories[selected].Buttons
		local n = table.maxn(buttons)

		local offset = Star_Trek.LCARS:GetButtonOffset(self.ButtonsStart, self.ButtonsHeight, n, pos.y)
		for i, button in pairs(buttons) do
			local y = Star_Trek.LCARS:GetButtonYPos(self.ButtonsHeight, i, n, offset)

			local state = 1
			if not button.Disabled then
				state = 2
				if button.Selected then
					state = state + 1
				end
				if pos.y >= y - 1 and pos.y <= y + (BUTTON_HEIGHT - 1) then
					state = state + 3
				end
			end

			local buttonAlpha = 255
			if y < self.ButtonsTopAlpha or y > self.ButtonsBotAlpha then
				if y < self.ButtonsTopAlpha then
					buttonAlpha = -y + self.ButtonsTopAlpha
				else
					buttonAlpha = y - self.ButtonsBotAlpha
				end
	
				buttonAlpha = math.min(math.max(0, 255 - buttonAlpha * 10), 255)
			end
			buttonAlpha = math.min(buttonAlpha, 255 * animPos)
			surface.SetDrawColor(255, 255, 255, buttonAlpha)
			
			Star_Trek.LCARS:RenderButton(x, y, button.MaterialData, state)
		end
	end
	
	surface.SetDrawColor(255, 255, 255, 255 * animPos)

	Star_Trek.LCARS:RenderFrame(self.FrameMaterialData)

	surface.SetAlphaMultiplier(1)
end
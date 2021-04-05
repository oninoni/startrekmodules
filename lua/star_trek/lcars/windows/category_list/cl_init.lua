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
--    LCARS Category List | Client   --
---------------------------------------

local BUTTON_HEIGHT = 32
-- TODO: Modularize the size of the buttons. (Interaction, Offsets, etc...)

local SELF = WINDOW
function WINDOW:OnCreate(windowData)
	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.Selected = windowData.Selected
	self.Categories = windowData.Categories

	self.CategoryStart = -self.HD2 + 79
	self.CategoryHeight = windowData.Height2
	
	self.ButtonsStart = self.CategoryStart + self.CategoryHeight
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

			table.insert(self.CategoryRows, self:SetupCategoryRow(subCategories))
		else
			table.insert(self.CategoryRows, self:SetupCategoryRow(categories))

			break
		end
	end

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

	return self
end

function WINDOW:SetupCategoryRow(categories)
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

function WINDOW:OnPress(pos, animPos)
	if pos.y <= -self.HD2 + self.CategoryHeight + 65 then
		for rowId, rowData in pairs(self.CategoryRows) do
			for butId, categoryData in pairs(rowData.Categories) do
				local xRow = self.XOffset + ((butId - 0.5) - rowData.N / 2) * rowData.Width
				local y = self.CategoryStart + (rowId - 1) * 35

				if self:IsButtonHovered(xRow, y, rowData.Width - 3, 32, pos) then
					return categoryData.Id
				end
			end
		end
	else
		local buttonId = SELF.Base.OnPress(self, pos, animPos)
		if isnumber(buttonId) then
			return #self.Categories + buttonId
		end
	end
end

function WINDOW:OnDraw(pos, animPos)
	surface.SetDrawColor(255, 255, 255, 255 * animPos)

	for rowId, rowData in pairs(self.CategoryRows) do
		for butId, categoryData in pairs(rowData.Categories) do
			local xRow = self.XOffset + ((butId - 0.5) - rowData.N / 2) * rowData.Width
			local y = self.CategoryStart + (rowId - 1) * 35
			
			local state = Star_Trek.LCARS:GetButtonState(categoryData.Disabled, self:IsButtonHovered(xRow, y, rowData.Width - 3, 32, pos), self.Selected == categoryData.Id)

			Star_Trek.LCARS:RenderButton(xRow, y, categoryData.MaterialData, state)
		end
	end

	SELF.Base.OnDraw(self, pos, animPos)
end
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
--    LCARS Category List | Server   --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(categories, title, titleShort, hFlip, toggle, buttonHeight, categoryButtonHeight, maxListHeight)
	local success = SELF.Base.OnCreate(self, {}, title, titleShort, hFlip, toggle, buttonHeight, maxListHeight)
	if not success then
		return false
	end

	if not istable(categories) then
		return false
	end

	self:SetCategories(categories, categoryButtonHeight)
	self:SetCategory(1)

	return true
end

function SELF:SetupCategoryRow(categories)
	local categoryRows = {}

	local totalCount = #categories

	local categoryCopy = table.Copy(categories)
	while true do
		local rowData = {}
		table.insert(categoryRows, rowData)

		if totalCount <= 4 then
			if #categoryCopy >= 2 then
				table.insert(rowData, table.remove(categoryCopy, 1))
				table.insert(rowData, table.remove(categoryCopy, 1))
			elseif #categoryCopy == 1 then
				table.insert(rowData, table.remove(categoryCopy, 1))
				table.insert(rowData, {
					Name = "",
					Color = Star_Trek.LCARS.ColorGrey,
					Disabled = true,
				})
			end
		else
			if #categoryCopy >= 4 then
				table.insert(rowData, table.remove(categoryCopy, 1))
				table.insert(rowData, table.remove(categoryCopy, 1))
				table.insert(rowData, table.remove(categoryCopy, 1))
				table.insert(rowData, table.remove(categoryCopy, 1))
			elseif #categoryCopy == 3 then
				table.insert(rowData, table.remove(categoryCopy, 1))
				table.insert(rowData, table.remove(categoryCopy, 1))
				table.insert(rowData, table.remove(categoryCopy, 1))
				table.insert(rowData, {
					Name = "",
					Color = Star_Trek.LCARS.ColorGrey,
					Disabled = true,
				})
			elseif #categoryCopy == 2 then
				table.insert(rowData, table.remove(categoryCopy, 1))
				table.insert(rowData, table.remove(categoryCopy, 1))
			elseif #categoryCopy == 1 then
				table.insert(rowData, table.remove(categoryCopy, 1))
				table.insert(rowData, {
					Name = "",
					Color = Star_Trek.LCARS.ColorGrey,
					Disabled = true,
				})
			end
		end

		if #categoryCopy <= 0 then
			break
		end
	end

	return categoryRows
end

function SELF:SetCategories(categories, categoryButtonHeight)
	self:ClearSecondaryButtons()

	local categoryRows = self:SetupCategoryRow(categories)

	self.Categories = {}

	local i = 1
	for _, rowData in pairs(categoryRows) do
		local row = self:CreateSecondaryButtonRow(categoryButtonHeight or 35)

		for _, category in pairs(rowData) do
			if not istable(category) then continue end

			local color = category.Color
			if not IsColor(color) then
				if i % 2 == 0 then
					color = Star_Trek.LCARS.ColorLightBlue
				else
					color = Star_Trek.LCARS.ColorBlue
				end
			end

			local categoryButtonData = self:AddButtonToRow(row,
				category.Name or "MISSING",
				nil,
				color, category.ActiveColor or Star_Trek.LCARS.ColorOrange,
				category.Disabled or false, toggle)

			categoryButtonData.Data = category.Data
			categoryButtonData.Buttons = category.Buttons

			table.insert(self.Categories, categoryButtonData)

			i = i + 1
		end
	end
end

function SELF:SetCategory(category)
	local oldCategoryButtonData = self.Categories[self.Selected]
	if istable(oldCategoryButtonData) then
		oldCategoryButtonData.Selected = false
	end

	self.Selected = category

	local categoryButtonData = self.Categories[self.Selected]
	if istable(categoryButtonData) then
		categoryButtonData.Selected = true

		self:SetButtons(categoryButtonData.Buttons)
	end
end

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	local shouldUpdate = false

	local categoryId = self.Selected
	local categoryCount = table.Count(self.Categories)

	if buttonId <= categoryCount then
		if buttonId == categoryId then
			return
		end

		local categoryButtonData = self.Categories[buttonId]
		if not istable(categoryButtonData) then return end

		if categoryButtonData.Disabled then return end

		self:SetCategory(buttonId)
		shouldUpdate = true

		if isfunction(callback) and callback(self, interfaceData, ply, buttonId, nil, categoryButtonData) == false then
			shouldUpdate = false
		end
	else
		local buttonData = self.Buttons[buttonId]
		if not istable(buttonData) then return end

		if buttonData.Disabled then return end

		if SELF.Base.OnPress(self, interfaceData, ply, buttonId) then
			shouldUpdate = true
		end

		if isfunction(callback) and callback(self, interfaceData, ply, categoryId, buttonId - categoryCount, buttonData) then
			shouldUpdate = true
		end
	end

	if shouldUpdate then
		interfaceData.Ent:EmitSound("star_trek.lcars_beep")
	end

	return shouldUpdate
end

function SELF:GetSelected()
	local data = {}

	data.Buttons = SELF.Base.GetSelected(self)
	data.Selected = self.Selected

	return data
end

function SELF:SetSelected(data)
	self:SetCategory(data.Selected)
	SELF.Base.SetSelected(self, data.Buttons)
end

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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--    LCARS Category List | Server   --
---------------------------------------

local SELF = WINDOW
function SELF:OnCreate(categories, title, titleShort, hFlip, toggle, buttonHeight, categoryButtonHeight)
	local success = SELF.Base.OnCreate(self, {}, title, titleShort, hFlip, toggle, buttonHeight)
	if not success then
		return false
	end

	if not istable(categories) then
		return false
	end

	self:SetCategoryButtonHeight(categoryButtonHeight)
	self:SetCategories(categories)

	return true
end

function SELF:SetCategories(categories, default)
	self.Height2 = math.max(2, math.ceil(table.Count(categories) / 4)) * 35 + 50
	self.Categories = {}
	for i, category in pairs(categories) do
		if not istable(category) or not istable(category.Buttons) then continue end

		local categoryData = {
			Name = category.Name or "MISSING",
			Disabled = category.Disabled or false,
			Data = category.Data,
			Buttons = {}
		}

		if IsColor(category.Color) then
			categoryData.Color = category.Color
		else
			if i % 2 == 0 then
				categoryData.Color = Star_Trek.LCARS.ColorLightBlue
			else
				categoryData.Color = Star_Trek.LCARS.ColorBlue
			end
		end

		categoryData.Buttons = category.Buttons

		categoryData.Id = table.insert(self.Categories, categoryData)
	end

	self.Selected = default or 1
	self:SetCategory(self.Selected)
end

function SELF:SetCategoryButtonHeight(categoryButtonHeight)
	self.CategoryButtonHeight = categoryButtonHeight or 32
end

function SELF:GetSelected()
	local data = {}

	data.Buttons = SELF.Base.GetSelected(self)
	data.Selected = self.Selected

	return data
end

function SELF:SetCategory(category)
	self.Selected = category

	self:SetButtons(self.Categories[self.Selected].Buttons)
end

function SELF:SetSelected(data)
	self:SetCategory(data.Selected)
	self.Base.SetSelected(self, data.Buttons)
end

function SELF:OnPress(interfaceData, ent, buttonId, callback)
	local shouldUpdate = false

	local categoryId = self.Selected
	local categoryCount = table.Count(self.Categories)

	if buttonId <= categoryCount then
		if buttonId == categoryId then
			return
		end

		self:SetCategory(buttonId)
		shouldUpdate = true

		if isfunction(callback) and callback(self, interfaceData, buttonId, nil) == false then
			shouldUpdate = false
		end
	else
		buttonId = buttonId - categoryCount

		if SELF.Base.OnPress(self, interfaceData, ent, buttonId, nil) then
			shouldUpdate = true
		end

		if isfunction(callback) and callback(self, interfaceData, categoryId, buttonId) then
			shouldUpdate = true
		end
	end

	if shouldUpdate then
		ent:EmitSound("star_trek.lcars_beep")
	end

	return shouldUpdate
end
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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--    LCARS Category List | Server   --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(categories, title, titleShort, hFlip, toggle, buttonHeight, categoryButtonHeight)
	local success = SELF.Base.OnCreate(self, {}, title, titleShort, hFlip, toggle, buttonHeight)
	if not success then
		return false
	end

	if not istable(categories) then
		return false
	end

	self:SetCategories(categories)

	self.CategoryButtonHeight = categoryButtonHeight or 32

	return true
end

function SELF:GetClientData()
	local clientData = SELF.Base.GetClientData(self)

	clientData.Categories = {}
	for i, categoryData in pairs(self.Categories) do
		local clientCategoryData = {
			Name = categoryData.Name,
			Disabled = categoryData.Disabled,

			Color = categoryData.Color,
		}

		clientData.Categories[i] = clientCategoryData
	end

	clientData.Selected = self.Selected
	clientData.CategoryButtonHeight = self.CategoryButtonHeight

	return clientData
end

function SELF:SetCategories(categories, default)
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

		table.insert(self.Categories, categoryData)
	end

	self:SetCategory(default or 1)
end

function SELF:GetSelected()
	local data = {}

	data.Buttons = SELF.Base.GetSelected(self)
	data.Selected = self.Selected

	return data
end

function SELF:SetCategory(category)
	self.Selected = category

	local categoryData = self.Categories[self.Selected]
	if categoryData then
		self:SetButtons(categoryData.Buttons)
	end
end

function SELF:SetSelected(data)
	self:SetCategory(data.Selected)
	self.Base.SetSelected(self, data.Buttons)
end

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	local shouldUpdate = false

	local categoryId = self.Selected
	local categoryCount = table.Count(self.Categories)

	if buttonId <= categoryCount then
		if buttonId == categoryId then
			return
		end

		self:SetCategory(buttonId)
		shouldUpdate = true

		if isfunction(callback) and callback(self, interfaceData, ply, buttonId, nil) == false then
			shouldUpdate = false
		end
	else
		buttonId = buttonId - categoryCount

		if SELF.Base.OnPress(self, interfaceData, ply, buttonId, nil) then
			shouldUpdate = true
		end

		if isfunction(callback) and callback(self, interfaceData, ply, categoryId, buttonId) then
			shouldUpdate = true
		end
	end

	if shouldUpdate then
		interfaceData.Ent:EmitSound("star_trek.lcars_beep")
	end

	return shouldUpdate
end
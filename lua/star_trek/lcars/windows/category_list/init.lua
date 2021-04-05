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
--    LCARS Category List | Server   --
---------------------------------------

local SELF = WINDOW
function WINDOW:OnCreate(categories, title, titleShort, hFlip, toggle)
	self.Selected = 1

	local success = SELF.Base.OnCreate(self, categories[self.Selected].Buttons, title, titleShort, hFlip, toggle)
	if not success then
		return false
	end

	if not istable(categories) then
		return false
	end

	self.Height2 = math.max(2, math.ceil(table.Count(categories) / 4)) * 35 + 50
	
	-- TODO: Check for redundancy.
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

	return true
end

function WINDOW:GetSelected()
	local data = {}

	data.Buttons = SELF.BASE.GetSelected(self)
	data.Selected = self.Selected

	return data
end

function WINDOW:SetCategory(category)
	self.Selected = category
	
	local height2 = self.Height2
	SELF.Base.OnCreate(self, self.Categories[self.Selected].Buttons, self.Title, self.TitleShort, self.HFlip, self.Toggle)
	self.Height2 = height2
end

function WINDOW:SetSelected(data)
	self:SetCategory(data.Selected)
	self.BASE.SetSelected(self, data.Buttons)
end

function WINDOW:OnPress(interfaceData, ent, buttonId, callback)
	local shouldUpdate = false
	
	local categoryId = self.Selected
	local categoryCount = table.Count(self.Categories)

	if buttonId <= categoryCount then
		if buttonId == categoryId then
			return
		end

		self:SetCategory(buttonId)
		shouldUpdate = true
		
		ent:EmitSound("star_trek.lcars_beep") -- Modularize Sound
		
		if isfunction(callback) then
			callback(self, interfaceData, ent, buttonId, nil)
		end
	else
		buttonId = buttonId - categoryCount

		if SELF.Base.OnPress(self, interfaceData, ent, buttonId, nil) then
			shouldUpdate = true
			
			ent:EmitSound("star_trek.lcars_beep") -- Modularize Sound
		end

		if isfunction(callback) and callback(self, interfaceData, ent, categoryId, buttonId) then
			shouldUpdate = true
		end
	end

	return shouldUpdate
end
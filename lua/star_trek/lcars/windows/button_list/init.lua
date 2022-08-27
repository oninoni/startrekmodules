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
--     LCARS Button List | Server    --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(buttons, title, titleShort, hFlip, toggle, buttonHeight)
	local success = SELF.Base.OnCreate(self, title, titleShort, hFlip)
	if not success then
		return false
	end

	if not istable(buttons) then
		return false
	end

	self:SetButtons(buttons, toggle, buttonHeight)

	return true
end

function SELF:SetButtons(buttons, toggle, buttonHeight)
	self:ClearMainButtons()

	local containsRandomNumber = false
	for i, button in pairs(buttons) do
		if not istable(button) then continue end

		if isnumber(button.RandomNumber) then
			containsRandomNumber = true
		end

		local color = button.Color
		if not IsColor(color) then
			if i % 2 == 0 then
				color = Star_Trek.LCARS.ColorLightBlue
			else
				color = Star_Trek.LCARS.ColorBlue
			end
		end

		local row = self:CreateMainButtonRow(buttonHeight or 35)
		local buttonData = self:AddButtonToRow(row,
			button.Name or "MISSING",
			button.RandomNumber,
			color, button.ActiveColor or Star_Trek.LCARS.ColorOrange,
			button.Disabled or false, toggle)

		buttonData.Data = button.Data
	end

	if not containsRandomNumber then
		for _, buttonRowData in pairs(self.MainButtons) do
			local buttonData = buttonRowData.Buttons[1]
			if not istable(buttonData) then continue end

			if math.random(0, 1) > 0 then
				buttonData.Number = math.random(0, 99)
			end
		end
	end
end

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	local shouldUpdate = false

	local buttonData = self.Buttons[buttonId]
	if not istable(buttonData) then return end

	if buttonData.Disabled then return end

	if buttonData.Toggle then
		buttonData.Selected = not (buttonData.Selected or false)
		shouldUpdate = true
	end

	if isfunction(callback) and callback(self, interfaceData, ply, buttonId) then
		shouldUpdate = true
	end

	if shouldUpdate then
		interfaceData.Ent:EmitSound("star_trek.lcars_beep")
	end

	return shouldUpdate
end

function SELF:GetSelected()
	local data = {}

	for i, buttonData in pairs(self.Buttons) do
		data[buttonData.Name] = buttonData.Selected
	end

	return data
end

function SELF:SetSelected(data)
	for i, buttonData in pairs(self.Buttons) do
		if data[buttonData.Name] then
			buttonData.Selected = true
		else
			buttonData.Selected = false
		end
	end
end
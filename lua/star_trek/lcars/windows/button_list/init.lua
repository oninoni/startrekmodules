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

function SELF:OnCreate(buttons, title, titleShort, hFlip, toggle, buttonHeight, maxListHeight)
	local success = SELF.Base.OnCreate(self, title, titleShort, hFlip, maxListHeight)
	if not success then
		return false
	end

	if not istable(buttons) then
		return false
	end

	self.Toggle = toggle or false

	self:SetButtons(buttons, buttonHeight)

	return true
end

function SELF:SetButtons(buttons, buttonHeight)
	self:ClearMainButtons()

	local containsRandomNumber = false
	local lastI = 0
	for i, button in SortedPairs(buttons) do
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

		-- Create Spacer Rows
		local diff = i - lastI
		if diff > 1 then
			for j = 2, diff do
				self:CreateMainButtonRow(buttonHeight or 35)
			end
		end

		local row = self:CreateMainButtonRow(buttonHeight or 35)
		local buttonData = self:AddButtonToRow(row,
			button.Name or "MISSING",
			button.RandomNumber,
			color, button.ActiveColor or Star_Trek.LCARS.ColorOrange,
			button.Disabled or false, self.Toggle or false)

		buttonData.Data = button.Data

		lastI = i
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

	if SELF.Base.OnPress(self, interfaceData, ply, buttonId) then
		shouldUpdate = true
	end

	if self.Toggle and self.PreviousButton ~= nil and self.PreviousButton ~= buttonId and ply:KeyDown(IN_SPEED) then
		local firstButton = math.min(self.PreviousButton, buttonId)
		local lastButton = math.max(self.PreviousButton, buttonId)

		--For getting whether or not you are mass selecting or mass deselecting
		local mode = self.Buttons[firstButton].Selected
		for i = firstButton, lastButton do
			local button = self.Buttons[i]
			button.Selected = mode
		end
		shouldUpdate = true
	end

	if isfunction(callback) and callback(self, interfaceData, ply, buttonId, buttonData) then
		shouldUpdate = true
	end

	self.PreviousButton = buttonId
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
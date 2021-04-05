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
--     LCARS Button List | Server    --
---------------------------------------

local SELF = WINDOW
function SELF:OnCreate(buttons, title, titleShort, hFlip, toggle)
	local success = SELF.Base.OnCreate(self, title, titleShort, hFlip)
	if not success then
		return false
	end

	if not istable(buttons) then
		return false
	end

	self:SetButtons(buttons)
	self:SetToggle(toggle)

	return true
end

function SELF:SetButtons(buttons)
	self.Buttons = {}
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
			if i % 2 == 0 then
				buttonData.Color = Star_Trek.LCARS.ColorLightBlue
			else
				buttonData.Color = Star_Trek.LCARS.ColorBlue
			end
		end

		buttonData.RandomS = button.RandomS
		buttonData.RandomL = button.RandomL

		self.Buttons[i] = buttonData
	end
end

function SELF:SetToggle(toggle)
	self.Toggle = toggle or false
end

function SELF:GetSelected()
	local data = {}

	for _, buttonData in pairs(self.Buttons) do
		data[buttonData.Name] = buttonData.Selected
	end

	return data
end

function SELF:SetSelected(data)
	for _, buttonData in pairs(self.Buttons) do
		if data[buttonData.Name] then
			buttonData.Selected = true
		else
			buttonData.Selected = false
		end
	end
end

function SELF:OnPress(interfaceData, ent, buttonId, callback)
	local shouldUpdate = false

	if self.Toggle then
		local buttonData = self.Buttons[buttonId]
		if istable(buttonData) then
			buttonData.Selected = not (buttonData.Selected or false)
			shouldUpdate = true

			ent:EmitSound("star_trek.lcars_beep") -- Modularize Sound
		end
	end

	if isfunction(callback) then
		shouldUpdate = shouldUpdate or callback(self, interfaceData, buttonId)
	end

	return shouldUpdate
end
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
--     LCARS Button List | Client    --
---------------------------------------

local BUTTON_HEIGHT = 32
-- TODO: Modularize the size of the buttons. (Interaction, Offsets, etc...)

local SELF = WINDOW
function SELF:OnCreate(windowData)
	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.Buttons = windowData.Buttons
	self.MaxN = table.maxn(self.Buttons)

	self.ButtonsHeight = self.WHeight - 80
	self.ButtonsStart = self.HD2 - self.ButtonsHeight

	self.ButtonsTopAlpha = self.ButtonsStart
	self.ButtonsBotAlpha = self.HD2 - 25

	self.ButtonWidth = self.WWidth - 64
	self.XOffset = self.HFlip and -24 or 24

	for id, button in pairs(self.Buttons) do
		button.MaterialData = Star_Trek.LCARS:CreateButton(
			self.Id .. "_" .. id,
			self.ButtonWidth,
			BUTTON_HEIGHT,
			button.Color,
			Star_Trek.LCARS.ColorYellow, -- TODO: Modularize
			button.Name or "[ERROR]",
			false,
			false,
			button.RandomL,
			button.RandomS
		)
	end

	return true
end

function SELF:IsButtonHovered(x, y, width, height, pos)
	return pos.x >= (x - width / 2) and pos.x <= (x + width / 2) and pos.y >= (y -1) and pos.y <= (y + height)
end

function SELF:OnPress(pos, animPos)
	local offset = Star_Trek.LCARS:GetButtonOffset(self.ButtonsStart, self.ButtonsHeight, BUTTON_HEIGHT + 3, self.MaxN, pos.y)

	for i, button in pairs(self.Buttons) do
		if button.Disabled then continue end

		local y = Star_Trek.LCARS:GetButtonYPos(self.ButtonsHeight, i, self.MaxN, offset)
		if self:IsButtonHovered(self.XOffset, y, self.ButtonWidth, BUTTON_HEIGHT, pos) then
			return i
		end
	end
end

function SELF:OnDraw(pos, animPos)
	local offset = Star_Trek.LCARS:GetButtonOffset(self.ButtonsStart, self.ButtonsHeight, BUTTON_HEIGHT + 3, self.MaxN, pos.y)

	for i, button in pairs(self.Buttons) do
		local y = Star_Trek.LCARS:GetButtonYPos(self.ButtonsHeight, i, self.MaxN, offset)

		local state = Star_Trek.LCARS:GetButtonState(button.Disabled, self:IsButtonHovered(self.XOffset, y, self.ButtonWidth, BUTTON_HEIGHT, pos), button.Selected)

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

		Star_Trek.LCARS:RenderButton(self.XOffset, y, button.MaterialData, state)
	end

	SELF.Base.OnDraw(self, pos, animPos)
end
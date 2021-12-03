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
--     LCARS Button List | Client    --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(windowData)
	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.ButtonHeight = windowData.ButtonHeight

	self.MaxN = table.maxn(windowData.Buttons)

	self.ButtonsHeight = self.WHeight - 80
	self.ButtonsStart = self.HD2 - self.ButtonsHeight

	self.ButtonsTopAlpha = self.ButtonsStart
	self.ButtonsBotAlpha = self.HD2 - 25

	self.ButtonWidth = self.WWidth - 64
	self.XOffset = self.HFlip and -24 or 24


	self.Buttons = {}
	for i, buttonData in pairs(windowData.Buttons) do
		-- TODO: Add negative ID Conversion here.
		local id = i

		local success, button = Star_Trek.LCARS:GenerateElement("button", self.Id .. "_" .. id, self.ButtonWidth, self.ButtonHeight, 
			buttonData.Name or "[ERROR]",
			buttonData.RandomL, buttonData.RandomS,
			buttonData.Color, buttonData.ActiveColor,
			false, false,
			buttonData.Disabled, buttonData.Selected, false)

		if not success then return false end

		self.Buttons[id] = button
	end

	return true
end

function SELF:IsButtonHovered(x, y, width, height, pos)
	return pos[1] >= (x - width / 2) and pos[1] <= (x + width / 2) and pos[2] >= (y -1) and pos[2] <= (y + height)
end

function SELF:OnPress(pos, animPos)
	local offset = Star_Trek.LCARS:GetButtonOffset(self.ButtonsStart, self.ButtonsHeight, self.ButtonHeight + 3, self.MaxN, pos[2])

	for i, button in pairs(self.Buttons) do
		if button.Disabled then continue end

		local y = Star_Trek.LCARS:GetButtonYPos(self.ButtonsHeight, self.ButtonHeight, i, self.MaxN, offset)
		if self:IsButtonHovered(self.XOffset, y, self.ButtonWidth, self.ButtonHeight, pos) then
			return i
		end
	end
end

function SELF:OnDraw(pos, animPos)
	local offset = Star_Trek.LCARS:GetButtonOffset(self.ButtonsStart, self.ButtonsHeight, self.ButtonHeight + 3, self.MaxN, pos[2])

	for i, button in pairs(self.Buttons) do
		local y = Star_Trek.LCARS:GetButtonYPos(self.ButtonsHeight, self.ButtonHeight, i, self.MaxN, offset)
		button.Hovered = self:IsButtonHovered(self.XOffset, y, self.ButtonWidth, self.ButtonHeight, pos)

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

		button:Render(self.XOffset, y)
	end

	SELF.Base.OnDraw(self, pos, animPos)
end
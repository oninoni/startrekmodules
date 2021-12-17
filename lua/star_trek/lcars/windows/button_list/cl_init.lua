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
	self.Padding = self.Padding or 1
	self.FrameType = self.FrameType or "frame_double"

	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.ButtonHeight = windowData.ButtonHeight

	self.MaxN = table.maxn(windowData.Buttons)

	self.Area1YEndAlpha = self.Area1YEnd - self.ButtonHeight

	self.Buttons = {}
	for i, buttonData in pairs(windowData.Buttons) do
		-- TODO: Add negative ID Conversion here.
		local id = i

		local successButton, button = self:GenerateElement("button", self.Id .. "_" .. id, self.Area1Width, self.ButtonHeight,
			buttonData.Name or "[ERROR]", buttonData.RandomNumber,
			buttonData.Color, buttonData.ActiveColor,
			self.HFlip, not self.HFlip,
			buttonData.Disabled, buttonData.Selected, false)
		if not successButton then return false end

		self.Buttons[id] = button
	end

	return true
end

function SELF:IsButtonHovered(x, y, xEnd, yEnd, pos)
	return pos[1] >= x and pos[1] <= xEnd and pos[2] >= y and pos[2] <= yEnd
end

function SELF:OnPress(pos, animPos)
	local offset = Star_Trek.LCARS:GetButtonOffset(self.Area1Y, self.Area1Height, self.ButtonHeight + 2, self.MaxN, pos[2])

	for i, button in pairs(self.Buttons) do
		if button.Disabled then continue end

		local y = Star_Trek.LCARS:GetButtonYPos(self.Area1Height, self.ButtonHeight, i, self.MaxN, offset)
		if self:IsButtonHovered(self.Area1X, y, self.Area1XEnd, y + self.ButtonHeight, pos) then
			return i
		end
	end
end

function SELF:OnDraw(pos, animPos)
	local offset = Star_Trek.LCARS:GetButtonOffset(self.Area1Y, self.Area1Height, self.ButtonHeight + 2, self.MaxN, pos[2])

	for i, button in pairs(self.Buttons) do
		local y = Star_Trek.LCARS:GetButtonYPos(self.Area1Height, self.ButtonHeight, i, self.MaxN, offset)
		button.Hovered = self:IsButtonHovered(self.Area1X, y, self.Area1XEnd, y + self.ButtonHeight, pos)

		local buttonAlpha = 255
		if y < self.Area1Y or y > self.Area1YEndAlpha then
			if y < self.Area1Y then
				buttonAlpha = -y + self.Area1Y
			else
				buttonAlpha = y - self.Area1YEndAlpha
			end

			buttonAlpha = math.min(math.max(0, 255 - buttonAlpha * 20), 255)
		end
		buttonAlpha = math.min(buttonAlpha, 255 * animPos)
		surface.SetDrawColor(255, 255, 255, buttonAlpha)

		button:Render(self.Area1X, y)
	end

	SELF.Base.OnDraw(self, pos, animPos)
end
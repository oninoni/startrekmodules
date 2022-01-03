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
--  LCARS Transport Slider | Client  --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(windowData)
	local successBase = SELF.Base.OnCreate(self, windowData)
	if not successBase then
		return false
	end

	local height = self.WHeight

	self.State = -height / 2
	self.TargetState = -height / 2

	return true
end

function SELF:OnPress(pos, animPos)
	if self.TargetState ~= self.State then return end

	local height = self.WHeight

	if self.TargetState == nil or self.TargetState < 0 then
		self.TargetState = height / 2
		self.Lerp = 0

		timer.Simple(2, function()
			self.TargetState = -height / 2
			self.Lerp = 0
		end)

		return 1
	end
end

function SELF:OnDraw(pos, animPos)
	local colorBlue = ColorAlpha(Star_Trek.LCARS.ColorBlue, animPos * 255)
	local colorYellow = ColorAlpha(Star_Trek.LCARS.ColorOrange, animPos * 255)

	local width = self.WWidth
	local wd2 = width / 2
	local wd3 = width / 3
	local height = self.WHeight
	local hd2 = height / 2
	--draw.RoundedBox(0, -wd2, -hd2, width, height, Color(127, 127, 127))

	local hd16 = hd2 / 8
	local wd6 = wd3 / 2
	local wd64 = wd2 / 32
	--local yHeight = (height) * animPos
	for i = 1, 16 do
		local yPos = -hd2 + (i-1) * hd16 + 1

		draw.RoundedBox(0, -wd6 - wd64 / 2, yPos, wd64, hd16 - 2, colorBlue)
		draw.RoundedBox(0,  wd6 - wd64 / 2, yPos, wd64, hd16 - 2, colorBlue)
	end

	if self.TargetState ~= nil and self.TargetState ~= self.State then
		self.State = Lerp(self.Lerp, -self.TargetState, self.TargetState)
		self.Lerp = self.Lerp + FrameTime() / 1.5
	end

	local y = -(self.State / height) * (height - hd16) - hd16 / 2

	for i = 1, 3 do
		draw.RoundedBox(0, (i-2) * wd3 -wd6 + wd64, y, wd3 - 2 * wd64, hd2-y, colorYellow)
	end
end
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
--    LCARS Single Frame | Client    --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(windowData)
	self.Padding = self.Padding or 0
	self.FrameType = self.FrameType or "frame"

	self.HFlip = windowData.HFlip

	if self.FrameType == "frame" then
		local success, frame = Star_Trek.LCARS:GenerateElement(self.FrameType, self.Id .. "_Frame", self.WWidth, self.WHeight,
			windowData.Title, windowData.TitleShort,
			windowData.Color1, windowData.Color2,
			self.HFlip)
		if not success then return false end
		self.Frame = frame

		self.Area1X = -self.WD2 + 2 * (self.HFlip and -self.Frame.CornerRadius or self.Frame.CornerRadius) + self.Padding
		self.Area1Y = -self.HD2 + self.Frame.StripHeight												   + self.Padding

		self.Area1Width  = self.WWidth  - 2 * self.Frame.CornerRadius -     self.Padding
		self.Area1Height = self.WHeight - 2 * self.Frame.StripHeight  - 2 * self.Padding

		self.Area1XEnd = self.Area1X + self.Area1Width
		self.Area1YEnd = self.Area1Y + self.Area1Height

		return true
	elseif self.FrameType == "frame_double" then
		
	elseif self.FrameType == "frame_triple" then
		
	end

	return false
end

function SELF:OnDraw(pos, animPos)
	surface.SetDrawColor(255, 255, 255, 255 * animPos)

	self.Frame:Render(-self.WD2, -self.HD2)
end
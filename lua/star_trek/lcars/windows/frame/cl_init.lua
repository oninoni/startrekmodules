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
	local successBase = SELF.Base.OnCreate(self, windowData)
	if not successBase then
		return false
	end

	self.Padding = self.Padding or 0
	self.FrameType = self.FrameType or windowData.FrameType or "frame"

	self.HFlip = windowData.HFlip

	if self.FrameType == "frame" then
		local success, frame = self:GenerateElement(self.FrameType, self.Id .. "_Frame", self.WWidth, self.WHeight,
			windowData.Title, windowData.TitleShort,
			windowData.Color1, windowData.Color2,
			self.HFlip)
		if not success then return false end
		self.Frame = frame

		self.Area1X = -self.WD2 + 2 * (self.HFlip and 0 or self.Frame.CornerRadius + self.Padding)
		self.Area1Width = self.WWidth - 2 * self.Frame.CornerRadius - self.Padding
		self.Area1XEnd = self.Area1X + self.Area1Width

		self.Area1Y = -self.HD2 + self.Frame.StripHeight + self.Padding
		self.Area1YEnd = -self.Area1Y
		self.Area1Height = self.Area1YEnd - self.Area1Y

		return true
	elseif self.FrameType == "frame_double" then
		local success, frame = self:GenerateElement(self.FrameType, self.Id .. "_DoubleFrame", self.WWidth, self.WHeight,
			windowData.Title, windowData.TitleShort,
			windowData.Color1, windowData.Color2, windowData.Color3,
			self.HFlip)
		if not success then return false end
		self.Frame = frame

		self.Area1X = -self.WD2 + 2 * (self.HFlip and 0 or self.Frame.CornerRadius + self.Padding)
		self.Area1Width = self.WWidth - 2 * self.Frame.CornerRadius - self.Padding
		self.Area1XEnd = self.Area1X + self.Area1Width

		self.Area1Y = -self.HD2 + self.Frame.StripHeight + 2 * self.Frame.CornerRadius + self.Padding + self.Frame.FrameOffset
		self.Area1YEnd = self.HD2
		self.Area1Height = self.Area1YEnd - self.Area1Y

		return true
	elseif self.FrameType == "frame_triple" then
		if not isnumber(self.SubMenuHeight) then
			return false
		end

		local success, frame = self:GenerateElement(self.FrameType, self.Id .. "_DoubleFrame", self.WWidth, self.WHeight,
		self.SubMenuHeight,
		windowData.Title, windowData.TitleShort,
		windowData.Color1, windowData.Color2, windowData.Color3, windowData.Color4,
		self.HFlip)
		if not success then return false end
		self.Frame = frame

		self.Area1X = -self.WD2 + 2 * (self.HFlip and 0 or self.Frame.CornerRadius + self.Padding)
		self.Area1Width = self.WWidth - 2 * self.Frame.CornerRadius - self.Padding
		self.Area1XEnd = self.Area1X + self.Area1Width

		self.Area2Y = -self.HD2 + self.Frame.StripHeight + 2 * self.Frame.CornerRadius + self.Padding + self.Frame.FrameOffset
		self.Area2Height = self.SubMenuHeight - 2 * self.Padding
		self.Area2YEnd = self.Area2Y + self.Area2Height

		self.Area1Y = self.Area2YEnd + 2 * self.Frame.StripHeight + self.Frame.FrameOffset + self.Padding
		self.Area1YEnd = self.HD2
		self.Area1Height = self.Area1YEnd - self.Area1Y

		return true
	end

	return false
end

function SELF:OnDraw(pos, animPos)
--	draw.RoundedBox(0, -self.WD2, -self.HD2, self.WWidth, self.WHeight, Color(255, 0, 0, 32))
--	draw.RoundedBox(0, self.Area1X, self.Area1Y, self.Area1Width, self.Area1Height, Color(0, 255, 0, 32))
--	if isnumber(self.Area2Y) then
--		draw.RoundedBox(0, self.Area1X, self.Area2Y, self.Area1Width, self.Area2Height, Color(0, 0, 255, 32))
--	end

	surface.SetDrawColor(255, 255, 255, 255 * animPos)

	self.Frame:Render(-self.WD2, -self.HD2)
end
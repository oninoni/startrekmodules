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
--    LCARS Single Frame | Client    --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:GenerateXArea()
	if self.HFlip == WINDOW_BORDER_LEFT then
		self.Area1X = 2 * self.Frame.CornerRadius + self.Padding
		self.Area1XEnd = self.WWidth - self.Padding
	elseif self.HFlip == WINDOW_BORDER_RIGHT then
		self.Area1X = self.Padding
		self.Area1XEnd = self.WWidth - 2 * self.Frame.CornerRadius - self.Padding
	elseif self.HFlip == WINDOW_BORDER_BOTH then
		self.Area1X = 2 * self.Frame.CornerRadius + self.Padding
		self.Area1XEnd = self.WWidth - 2 * self.Frame.CornerRadius - self.Padding
	end

	self.Area1Width = self.Area1XEnd - self.Area1X
end

function SELF:OnCreate(windowData)
	local successBase = SELF.Base.OnCreate(self, windowData)
	if not successBase then
		return false
	end

	self.Padding = self.Padding or 0
	self.FrameType = self.FrameType or windowData.FrameType or "frame"

	self.HFlip = windowData.HFlip or WINDOW_BORDER_LEFT

	if self.FrameType == "frame" then
		local success, frame = self:GenerateElement(self.FrameType, self.Id .. "_Frame", self.WWidth, self.WHeight,
			windowData.Title, windowData.TitleShort,
			windowData.Color1, windowData.Color2,
			self.HFlip)
		if not success then return false end
		self.Frame = frame

		self:GenerateXArea()

		self.Area1Y = self.Frame.StripHeight + self.Padding
		self.Area1YEnd = self.WHeight - self.Area1Y
		self.Area1Height = self.Area1YEnd - self.Area1Y

		return true
	elseif self.FrameType == "frame_double" then
		local success, frame = self:GenerateElement(self.FrameType, self.Id .. "_DoubleFrame", self.WWidth, self.WHeight,
			windowData.Title, windowData.TitleShort,
			windowData.Color1, windowData.Color2, windowData.Color3,
			self.HFlip)
		if not success then return false end
		self.Frame = frame

		self:GenerateXArea()

		self.Area1Y = self.Frame.StripHeight + 2 * self.Frame.CornerRadius + self.Padding + self.Frame.FrameOffset
		self.Area1YEnd = self.WHeight
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

		self:GenerateXArea()

		self.Area2Y = self.Frame.StripHeight + 2 * self.Frame.CornerRadius + self.Padding + self.Frame.FrameOffset
		self.Area2Height = self.SubMenuHeight - 2 * self.Padding
		self.Area2YEnd = self.Area2Y + self.Area2Height

		self.Area1Y = self.Area2YEnd + 2 * self.Frame.StripHeight + self.Frame.FrameOffset + self.Padding
		self.Area1YEnd = self.WHeight
		self.Area1Height = self.Area1YEnd - self.Area1Y

		return true
	end

	return false
end

function SELF:OnDraw(pos, animPos)
	surface.SetDrawColor(255, 255, 255, 255 * animPos)

	self.Frame:Render(0, 0)
end
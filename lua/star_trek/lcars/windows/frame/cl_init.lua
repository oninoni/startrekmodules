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
	self.HFlip = windowData.HFlip

	local success, frame = Star_Trek.LCARS:GenerateElement("frame", self.Id .. "_Frame", self.WWidth, self.WHeight,
		title, titleShort,
		windowData.Color1, windowData.Color2,
		self.HFlip)
	if not success then return false end

	self.Frame = frame

	--[[
	self.FrameMaterialData = Star_Trek.LCARS:CreateFrame(
		self.Id,
		self.WWidth,
		self.WHeight,
		windowData.Title,
		windowData.TitleShort,
		windowData.Color1,
		windowData.Color2,
		windowData.Color3,
		self.HFlip,
		windowData.Inverted,
		windowData.Height2,
		windowData.Color4
	)]]

	return true
end

function SELF:OnDraw(pos, animPos)
	draw.RoundedBox(0, -self.WD2, -self.HD2, self.WWidth, self.WHeight, Color(255, 0, 0, 32))

	surface.SetDrawColor(255, 255, 255, 255 * animPos)

	self.Frame:Render(-self.WD2, -self.HD2)
end
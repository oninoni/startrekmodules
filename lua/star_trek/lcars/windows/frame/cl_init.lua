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
	)

	return true
end

function SELF:OnDraw(pos, animPos)
	surface.SetDrawColor(255, 255, 255, 255 * animPos)

	Star_Trek.LCARS:RenderFrame(self.FrameMaterialData)
end
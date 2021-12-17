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
--   Frame Triple Element | Client   --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

include("cl_draw.lua")

SELF.BaseElement = "frame_double"

SELF.Variants = 1

function SELF:Initialize(subMenuHeight, title, titleShort, color1, color2, color3, color4, hFlip)
	SELF.Base.Initialize(self, title, titleShort, color1, color2, color3, hFlip)

	self.SubMenuHeight = subMenuHeight
	self.Color4 = color4

	-- LCARS Design Parameters
	self.CornerRadius = 25
	self.InnerRadius = 20
	self.BorderWidth = 2
	self.StripHeight = 10
	self.FrameOffset = 2

	-- Adjusting SubMenuHeight
	self.SubMenuHeight = self.SubMenuHeight + 2 * self.StripHeight + self.FrameOffset
end

-- Style Changing function to be overridden.
--
-- @param String style
function SELF:ChangeStyle(style)
	SELF.Base.ChangeStyle(self, style)

	if style == "LCARS_RED" then
		self.StyleBackup.Color4 = self.Color4

		self.Color4 = Star_Trek.LCARS.ColorWhite
	end
end

-- Draw a given Variant of the element.
--
-- @param Number x
-- @param Number y
-- @param Number i
function SELF:DrawElement(i, x, y)
	self:DrawTripleFrame(x, y, self.ElementWidth, self.ElementHeight, self.SubMenuHeight, self.Color1, self.Color2, self.Color3, self.Color4, self.Title, self.TitleShort, self.HFlip)
end
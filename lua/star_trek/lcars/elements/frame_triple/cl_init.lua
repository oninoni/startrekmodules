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
function SELF:ApplyStyle()
	if self.CurrentStyle == "LCARS_RED" then
		self.Variants = 5

		return
	end

	self.Variants = nil
end

-- Draw a given Variant of the element.
--
-- @param Number x
-- @param Number y
-- @param Number i
function SELF:DrawElement(i, x, y)
	if self.CurrentStyle == "LCARS_RED" then
		if i == 1 then
			self:DrawTripleFrame(x, y, self.ElementWidth, self.ElementHeight, self.SubMenuHeight,
			Star_Trek.LCARS.ColorRed, Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorWhite,
			self.Title, self.TitleShort, self.HFlip)
		elseif i == 2 then
			self:DrawTripleFrame(x, y, self.ElementWidth, self.ElementHeight, self.SubMenuHeight,
			Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorRed, Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorWhite,
			self.Title, self.TitleShort, self.HFlip)
		elseif i == 3 then
			self:DrawTripleFrame(x, y, self.ElementWidth, self.ElementHeight, self.SubMenuHeight,
			Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorRed, Star_Trek.LCARS.ColorWhite,
			self.Title, self.TitleShort, self.HFlip)
		elseif i == 4 then
			self:DrawTripleFrame(x, y, self.ElementWidth, self.ElementHeight, self.SubMenuHeight,
			Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorRed,
			self.Title, self.TitleShort, self.HFlip)
		else
			self:DrawTripleFrame(x, y, self.ElementWidth, self.ElementHeight, self.SubMenuHeight,
			Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorWhite,
			self.Title, self.TitleShort, self.HFlip)
		end

		return
	end

	self:DrawTripleFrame(x, y, self.ElementWidth, self.ElementHeight, self.SubMenuHeight,
	self.Color1, self.Color2, self.Color3, self.Color4,
	self.Title, self.TitleShort, self.HFlip)
end

local SPEED = 4

function SELF:GetVariant()
	if self.CurrentStyle == "LCARS_RED" then
		local delta = ((self.LifeTime * SPEED) % 6)

		if delta < 1 then
			return 1
		elseif delta < 2 then
			return 2
		elseif delta < 3 then
			return 3
		elseif delta < 4 then
			return 4
		else
			return 5
		end
	end

	return 1
end
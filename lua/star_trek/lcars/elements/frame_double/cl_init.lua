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
--   Frame Double Element | Client   --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

include("cl_util.lua")
include("cl_draw.lua")

SELF.BaseElement = "frame"

SELF.Variants = 1

function SELF:Initialize(title, titleShort, color1, color2, color3, hFlip)
	SELF.Base.Initialize(self, title, titleShort, color1, color2, hFlip)

	self.Color3 = color3

	-- LCARS Design Parameters
	self.CornerRadius = 25
	self.InnerRadius = 20
	self.BorderWidth = 2
	self.StripHeight = 10
	self.FrameOffset = 2
end

-- Style Changing function to be overridden.
--
-- @param String style
function SELF:ApplyStyle()
	if self.CurrentStyle == "LCARS_RED" then
		self.Variants = 4

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
			self:DrawDoubleFrame(x, y, self.ElementWidth, self.ElementHeight,
			Star_Trek.LCARS.ColorRed, Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorWhite,
			self.Title, self.TitleShort, self.HFlip)
		elseif i == 2 then
			self:DrawDoubleFrame(x, y, self.ElementWidth, self.ElementHeight,
			Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorRed, Star_Trek.LCARS.ColorWhite,
			self.Title, self.TitleShort, self.HFlip)
		elseif i == 3 then
			self:DrawDoubleFrame(x, y, self.ElementWidth, self.ElementHeight,
			Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorRed,
			self.Title, self.TitleShort, self.HFlip)
		else
			self:DrawDoubleFrame(x, y, self.ElementWidth, self.ElementHeight,
			Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorWhite,
			self.Title, self.TitleShort, self.HFlip)
		end

		return
	end

	self:DrawDoubleFrame(x, y, self.ElementWidth, self.ElementHeight,
	self.Color1, self.Color2, self.Color3,
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
		else
			return 4
		end
	end

	return 1
end
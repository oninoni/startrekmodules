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
--    LCARS Frame Element | Client   --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

include("cl_util.lua")
include("cl_draw.lua")

SELF.BaseElement = "base"

SELF.Variants = 1

function SELF:Initialize(title, titleShort, color1, color2, hFlip)
	SELF.Base.Initialize(self)

	self.Title = title or ""
	self.TitleShort = titleShort or ""

	self.Color1 = color1 or table.Random(Star_Trek.LCARS.Colors)
	self.Color2 = color2 or table.Random(Star_Trek.LCARS.Colors)

	-- LCARS Design Parameters
	self.CornerRadius = 25
	self.InnerRadius = 20
	self.BorderWidth = 2
	self.StripHeight = 20

	self.HFlip = hFlip or false
end

-- Draw a given Variant of the element.
--
-- @param Number x
-- @param Number y
-- @param Number i
function SELF:DrawElement(i, x, y)
	self:DrawFrame(x, y, self.ElementWidth, self.ElementHeight, self.Color1, self.Color2, self.Title, self.TitleShort, self.HFlip)
end
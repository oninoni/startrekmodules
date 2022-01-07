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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--   LCARS Button Element | Client   --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

include("cl_draw.lua")

SELF.BaseElement = "base"

SELF.Variants = 1

function SELF:Initialize(sections, offset, scale)
	SELF.Base.Initialize(self)

	self.Sections = sections
	self.Offset = offset or Vector()
	self.Scale = scale or 1
end

function SELF:DrawElement(i, x, y)
	if self.CurrentStyle == "LCARS_RED" then
		self:DrawMap(x, y, Star_Trek.LCARS.ColorRed, Star_Trek.LCARS.ColorWhite, 1)
		self:DrawMap(x, y, Star_Trek.LCARS.ColorWhite, Star_Trek.LCARS.ColorRed, 0)

		return
	end

	self:DrawMap(x, y, Star_Trek.LCARS.ColorLightBlue, Star_Trek.LCARS.ColorWhite, 1)
	self:DrawMap(x, y, Star_Trek.LCARS.ColorBlue, Star_Trek.LCARS.ColorOrange, 0)
end
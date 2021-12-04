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
	self.FrameOffset = 4
end

-- Draw a given Variant of the element.
--
-- @param Number x
-- @param Number y
-- @param Number i
function SELF:DrawElement(i, x, y)
	self:DrawDoubleFrame(x, y, self.ElementWidth, self.ElementHeight, self.Color1, self.Color2, self.Color3, self.Title, self.TitleShort, self.HFlip)
end
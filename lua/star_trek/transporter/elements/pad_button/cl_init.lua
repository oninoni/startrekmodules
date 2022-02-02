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
-- LCARS Pad Button Element | Client --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

include("cl_draw.lua")

SELF.BaseElement = "button"

SELF.Variants = 5

function SELF:Initialize(number, color, selectedColor, round, disabled, selected, hovered)
	SELF.Base.Initialize(self, "", number, color, selectedColor, false, false, disabled, selected, hovered)

	self.Round = round or false
end

-- Draw a given Variant of the element.
--
-- @param Number x
-- @param Number y
-- @param Number i
function SELF:DrawElement(i, x, y)
	color = self.Color

	if self.CurrentStyle == "LCARS_RED" then
		color = Star_Trek.LCARS.ColorWhite
	end

	if i > 3 then
		if self.CurrentStyle == "LCARS_RED" then
			color = Star_Trek.LCARS.ColorRed
		else
			color = self.SelectedColor
		end
	elseif i == 1 then
		color = Star_Trek.LCARS.ColorGrey
	end

	borderColor = Star_Trek.LCARS.ColorBlack
	if i % 2 == 0 then
		borderColor = Star_Trek.LCARS.ColorWhite

		if self.CurrentStyle == "LCARS_RED" then
			color = Star_Trek.LCARS.ColorRed
		end
	end

	self:DrawPadButton(x, y, color, borderColor, self.Round, self.Number)
end

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
--   LCARS Button Element | Client   --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

include("cl_util.lua")
include("cl_draw.lua")

SELF.BaseElement = "base"

SELF.Variants = 5

--[[
Variants are:

1 Disabled
2 Active Hovered
3 Active
4 Selected Hovered
5 Selected
]]

function SELF:Initialize(text, largeNumber, smallNumber, color, selectedColor, flatLeft, flatRight, disabled, selected, hovered)
	SELF.Base.Initialize(self)

	self.Text = text or ""
	self.LargeNumber = self:ConvertLargeNumber(largeNumber or math.random(0, 999999))
	self.SmallNumber = self:ConvertSmallNumber(smallNumber or math.random(0, 99))

	self.FlatLeft = flatLeft or false
	self.FlatRight = flatRight or false
	self.Color = color or table.Random(Star_Trek.LCARS.Colors)
	self.SelectedColor = selectedColor or Star_Trek.LCARS.ColorYellow

	self.Disabled = disabled or false
	self.Selected = selected or false
	self.Hovered = hovered or false
end

-- Draw a given Variant of the element.
--
-- @param Number x
-- @param Number y
-- @param Number i
function SELF:DrawElement(i, x, y)
	color = self.Color
	if i > 3 then
		color = self.SelectedColor
	elseif i == 0 then
		color = Star_Trek.LCARS.ColorGrey
	end

	borderColor = Star_Trek.LCARS.ColorBlack
	if i % 2 == 0 then
		borderColor = Star_Trek.LCARS.ColorWhite
	end

	self:DrawButton(x, y, color, borderColor, self.Text, self.FlatLeft, self.FlatRight, self.LargeNumber, self.SmallNumber, 8)
end

-- Returns the current variant of the button.
--
-- @return Number variant
function SELF:GetVariant()
	if self.Disabled then
		return 1
	end

	local variant = 2
	if self.Selected then
		variant = variant + 2
	end
	if not self.Hovered then
		variant = variant + 1
	end

	return variant
end
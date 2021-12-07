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
--    Frame Double Element | Draw    --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

-- Draw a double frame for an LCARS interface.
--
-- @param Number x
-- @param Number y
-- @param Number width
-- @param Number height
-- @param Color color1
-- @param Color color2
-- @param Color color3
-- @param String title
-- @param String titleShort
-- @param? Boolean hFlip
function SELF:DrawDoubleFrame(x, y, width, height, color1, color2, color3, title, titleShort, hFlip)
	self:DrawSweptBreak(x, y, width, color1, color2, hFlip)

	if hFlip then
		draw.SimpleText(string.upper(title), "LCARSMed",         8, 2, nil, TEXT_ALIGN_LEFT,  TEXT_ALIGN_TOP)
	else
		draw.SimpleText(string.upper(title), "LCARSMed", width - 8, 2, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	end

	local posOffset = 0
	if hFlip then
		posOffset = width - self.CornerRadius * 2
	end

	local frameStartOffset = self.CornerRadius * 4 + self.FrameOffset
	local remainingHeight = height - frameStartOffset

	draw.RoundedBox(0,
		posOffset,
		frameStartOffset,
		self.CornerRadius * 2, remainingHeight,
	Star_Trek.LCARS.ColorBlack)

	draw.RoundedBox(0,
		posOffset + self.BorderWidth,
		frameStartOffset + self.BorderWidth,
		self.CornerRadius * 2 - self.BorderWidth * 2, remainingHeight / 2 - self.BorderWidth,
	color2)

	draw.RoundedBox(0,
		posOffset + self.BorderWidth,
		frameStartOffset + self.BorderWidth + remainingHeight / 2,
		self.CornerRadius * 2 - self.BorderWidth * 2, remainingHeight / 2 - self.BorderWidth,
	color3)

	draw.SimpleText(titleShort, "LCARSSmall", posOffset + self.CornerRadius, frameStartOffset, Star_Trek.LCARS.ColorBlack, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end
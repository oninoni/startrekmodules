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
--    Frame Triple Element | Draw    --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

-- Draw a triple frame for an LCARS interface.
--
-- @param Number x
-- @param Number y
-- @param Number width
-- @param Number height
-- @param Number height2
-- @param Color color1
-- @param Color color2
-- @param Color color3
-- @param Color color4
-- @param String title
-- @param String titleShort
-- @param? Boolean hFlip
function SELF:DrawTripleFrame(x, y, width, height, height2, color1, color2, color3, color4, title, titleShort, hFlip)
	self:DrawSweptBreak(x,       y, width, color1, color2, hFlip)

	if hFlip then
		draw.SimpleText(string.upper(title), "LCARSMed", x +         8, y + 2, nil, TEXT_ALIGN_LEFT,  TEXT_ALIGN_TOP)
	else
		draw.SimpleText(string.upper(title), "LCARSMed", x + width - 8, y + 2, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	end

	local posOffset = 0
	if hFlip then
		posOffset = width - self.CornerRadius * 2
	end

	local topFrameStartOffset = self.CornerRadius * 4 + self.FrameOffset

	draw.RoundedBox(0,
		x + posOffset,
		y + topFrameStartOffset,
		self.CornerRadius * 2, height2 - topFrameStartOffset,
	Star_Trek.LCARS.ColorBlack)

	draw.RoundedBox(0,
		x + posOffset + self.BorderWidth,
		y + topFrameStartOffset + self.BorderWidth,
		self.CornerRadius * 2 - self.BorderWidth * 2, height2 - topFrameStartOffset - self.BorderWidth,
	color2)

	self:DrawSweptBreak(x, y + height2, width, color2, color3, hFlip)

	local bottomFrameStarOffset = height2 + topFrameStartOffset
	local remainingHeight = height - bottomFrameStarOffset

	draw.RoundedBox(0,
		x + posOffset,
		y + bottomFrameStarOffset,
		self.CornerRadius * 2, remainingHeight,
	Star_Trek.LCARS.ColorBlack)

	draw.RoundedBox(0,
		x + posOffset + self.BorderWidth,
		y + bottomFrameStarOffset + self.BorderWidth,
		self.CornerRadius * 2 - self.BorderWidth * 2, remainingHeight / 2 - self.BorderWidth,
	color3)

	draw.RoundedBox(0,
		x + posOffset + self.BorderWidth,
		y + bottomFrameStarOffset + self.BorderWidth + remainingHeight / 2,
		self.CornerRadius * 2 - self.BorderWidth * 2, remainingHeight / 2 - self.BorderWidth,
	color4)

	draw.SimpleText(titleShort, "LCARSSmall", x + posOffset + self.CornerRadius, y + topFrameStartOffset, Star_Trek.LCARS.ColorBlack, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end
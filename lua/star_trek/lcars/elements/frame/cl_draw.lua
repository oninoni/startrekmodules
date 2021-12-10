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
--     LCARS Frame Element | Draw    --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

-- Draw a single frame for an LCARS interface.
--
-- @param Number x
-- @param Number y
-- @param Number width
-- @param Number height
-- @param Color color1
-- @param Color color2
-- @param String title
-- @param String titleShort
-- @param? Boolean hFlip
function SELF:DrawFrame(x, y, width, height, color1, color2, title, titleShort, hFlip)
	local titleUpper = string.upper(title)

	surface.SetFont("LCARSMed")
	local textWidth = surface.GetTextSize(titleUpper)
	if textWidth > 0 then
		textWidth = textWidth + 2
	end

	self:DrawSwept(x, y                                 , width, color1, hFlip,  true, textWidth)
	self:DrawSwept(x, y + height - self.CornerRadius * 2, width, color2, hFlip, false)

	if hFlip then
		draw.SimpleText(titleUpper, "LCARSMed", x + math.ceil(width * 0.05) - self.BorderWidth + 1, y + self.StripHeight / 2, nil,  TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText(titleUpper, "LCARSMed", x + math.floor(width * 0.95)                      , y + self.StripHeight / 2, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	local posOffset = 0
	if hFlip then
		posOffset = width - self.CornerRadius * 2
	end

	local frameStartOffset = self.CornerRadius * 2
	local remainingHeight = height - frameStartOffset - self.CornerRadius * 2

	draw.RoundedBox(0,
		x + posOffset,
		y + frameStartOffset,
		self.CornerRadius * 2, remainingHeight,
	Star_Trek.LCARS.ColorBlack)

	draw.RoundedBox(0,
		x + posOffset + self.BorderWidth,
		y + frameStartOffset + self.BorderWidth,
		self.CornerRadius * 2 - self.BorderWidth * 2, remainingHeight / 2 - self.BorderWidth,
	color1)

	draw.RoundedBox(0,
		x + posOffset + self.BorderWidth,
		y + frameStartOffset + self.BorderWidth + remainingHeight / 2,
		self.CornerRadius * 2 - self.BorderWidth * 2, remainingHeight / 2 - self.BorderWidth,
	color2)

	draw.SimpleText(titleShort, "LCARSSmall", x + posOffset + self.CornerRadius, y + frameStartOffset, Star_Trek.LCARS.ColorBlack, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end
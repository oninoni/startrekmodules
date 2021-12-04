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
--       LCARS Frame | Element       --
---------------------------------------

local LCARS_FRAME_OFFSET = 4

-- Draws a frame spacer.
--
-- @param Number y
-- @param Number width
-- @param Color top_color
-- @param Color bottom_color
-- @param Boolean hFlip
function Star_Trek.LCARS:DrawFrameSpacer(y, width, top_color, bottom_color, hFlip)
	Star_Trek.LCARS:DrawFrameBorder(y, width, top_color, false, hFlip)
	Star_Trek.LCARS:DrawFrameBorder(y + LCARS_CORNER_RADIUS * 2 + LCARS_FRAME_OFFSET, width, bottom_color, true, hFlip)
end













function Star_Trek.LCARS:DrawFrame(width, height, title, titleShort, color1, color2, color3, hFlip)
	Star_Trek.LCARS:DrawFrameSpacer(0, width, color1, color2, hFlip)

	if hFlip then
		draw.SimpleText(string.upper(title), "LCARSMed", width * 0.05, 3, nil, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	else
		draw.SimpleText(string.upper(title), "LCARSMed", width * 0.95, 3, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	end

	local posOffset = 0
	if hFlip then
		posOffset = width - LCARS_CORNER_RADIUS * 2
	end

	local frameStartOffset = LCARS_CORNER_RADIUS * 4 + LCARS_FRAME_OFFSET
	local remainingHeight = height - frameStartOffset

	draw.RoundedBox(0,
		posOffset,
		frameStartOffset,
		LCARS_CORNER_RADIUS * 2, remainingHeight,
	Star_Trek.LCARS.ColorBlack)

	draw.RoundedBox(0,
		posOffset + LCARS_BORDER_WIDTH,
		frameStartOffset + LCARS_BORDER_WIDTH,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
	color2)

	draw.RoundedBox(0,
		posOffset + LCARS_BORDER_WIDTH,
		frameStartOffset + LCARS_BORDER_WIDTH + remainingHeight / 2,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
	color3)

	draw.SimpleText(titleShort, "LCARSSmall", posOffset + LCARS_CORNER_RADIUS, frameStartOffset, Star_Trek.LCARS.ColorBlack, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

function Star_Trek.LCARS:DrawDoubleFrame(width, height, title, titleShort, color1, color2, color3, height2, color4, hFlip)
	Star_Trek.LCARS:DrawFrameSpacer(0, width, color1, color2, hFlip)
	if hFlip then
		draw.SimpleText(title, "LCARSMed", width * 0.05, 3, nil, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	else
		draw.SimpleText(title, "LCARSMed", width * 0.95, 3, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	end

	local posOffset = 0
	if hFlip then
		posOffset = width - LCARS_CORNER_RADIUS * 2
	end

	local topFrameStartOffset = LCARS_CORNER_RADIUS * 4 + LCARS_FRAME_OFFSET

	draw.RoundedBox(0,
		posOffset,
		topFrameStartOffset,
		LCARS_CORNER_RADIUS * 2, height2 - topFrameStartOffset,
	Star_Trek.LCARS.ColorBlack)

	draw.RoundedBox(0,
		posOffset + LCARS_BORDER_WIDTH,
		topFrameStartOffset + LCARS_BORDER_WIDTH,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, height2 - topFrameStartOffset - LCARS_BORDER_WIDTH,
	color2)

	Star_Trek.LCARS:DrawFrameSpacer(height2, width, color2, color3, hFlip)

	local bottomFrameStarOffset = height2 + topFrameStartOffset
	local remainingHeight = height - bottomFrameStarOffset

	draw.RoundedBox(0,
		posOffset,
		bottomFrameStarOffset,
		LCARS_CORNER_RADIUS * 2, remainingHeight,
	Star_Trek.LCARS.ColorBlack)

	draw.RoundedBox(0,
		posOffset + LCARS_BORDER_WIDTH,
		bottomFrameStarOffset + LCARS_BORDER_WIDTH,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
	color3)

	draw.RoundedBox(0,
		posOffset + LCARS_BORDER_WIDTH,
		bottomFrameStarOffset + LCARS_BORDER_WIDTH + remainingHeight / 2,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
	color4)

	draw.SimpleText(titleShort, "LCARSSmall", posOffset + LCARS_CORNER_RADIUS, topFrameStartOffset, Star_Trek.LCARS.ColorBlack, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end
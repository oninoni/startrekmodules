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

function Star_Trek.LCARS:CreateFrame(id, width, height, title, titleShort, color1, color2, color3, hFlip, inverted, height2, color4)
	--[[
	
	return Star_Trek.LCARS:CreateMaterial("Frame_" .. id, width, height, function()
		color1 = color1 or table.Random(Star_Trek.LCARS.Colors)
		color2 = color2 or table.Random(Star_Trek.LCARS.Colors)
		color3 = color3 or table.Random(Star_Trek.LCARS.Colors)
		color4 = color4 or table.Random(Star_Trek.LCARS.Colors)

		draw.RoundedBox(0, 0, 0, width, height, Color(128, 0, 0))

		if inverted then
			if isnumber(height2) then
				--Star_Trek.LCARS:DrawDoubleFrame(width, height, title, titleShort, color1, color2, color3, height2, color4, hFlip)
				return
			else
				Star_Trek.LCARS:DrawInvertedFrame(width, height, title, titleShort, color1, color2, hFlip)
			end
		else
			if isnumber(height2) then
				Star_Trek.LCARS:DrawDoubleFrame(width, height, title, titleShort, color1, color2, color3, height2, color4, hFlip)
			else
				Star_Trek.LCARS:DrawFrame(width, height, title, titleShort, color1, color2, color3, hFlip)
			end
		end

		for i = 0, 20 do
			draw.RoundedBox(0, 0, i * 20, 1, 20, Color(255, 255, 255))
			draw.RoundedBox(0, 0, i * 20 + 10, 50, 1, Color(255, 255, 255))
			draw.RoundedBox(0, 0, i * 20, 100, 1, Color(255, 255, 255))

			draw.SimpleText(i * 20, "LCARSSmall", 100, i * 20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end)]]
end

-- Renders the given Frame.
--
-- @param Table materialData
function Star_Trek.LCARS:RenderFrame(materialData)
	--[[
	surface.SetMaterial(materialData.Material)

	surface.DrawTexturedRectUV(-materialData.Width / 2, -materialData.Height / 2, materialData.Width, materialData.Height, 0, 0, materialData.U, materialData.V)]]
end
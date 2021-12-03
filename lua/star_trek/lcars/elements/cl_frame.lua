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

local LCARS_CORNER_RADIUS = 25
local LCARS_INNER_RADIUS = 15
local LCARS_FRAME_OFFSET = 4
local LCARS_BORDER_WIDTH = 2
local LCARS_STRIP_HEIGHT = 20

-- Draw the shape of a LCARS frame border.
--
-- @param Number y
-- @param Number width
-- @param Number border
-- @param Color color
-- @param? Boolean vFlip
-- @param? Boolean hFlip
function Star_Trek.LCARS:DrawFrameBorderShape(y, width, border, color, vFlip, hFlip, holeSize)
	holeSize = holeSize or 0

	-- Outer Circle
	if hFlip then
		Star_Trek.LCARS:DrawCircle(
			width - LCARS_CORNER_RADIUS,
			y + LCARS_CORNER_RADIUS,
			LCARS_CORNER_RADIUS - border, 16,
		color)
	else
		Star_Trek.LCARS:DrawCircle(
			LCARS_CORNER_RADIUS,
			y + LCARS_CORNER_RADIUS,
			LCARS_CORNER_RADIUS - border, 16,
		color)
	end

	-- Flat Piece (Below Rounded Part)
	if hFlip then
		if vFlip then
			draw.RoundedBox(0,
				width - LCARS_CORNER_RADIUS * 2 + border,
				y + LCARS_CORNER_RADIUS,
				(LCARS_CORNER_RADIUS - border) * 2, LCARS_CORNER_RADIUS,
			color)
		else
			draw.RoundedBox(0,
				width - LCARS_CORNER_RADIUS * 2 + border,
				y,
				(LCARS_CORNER_RADIUS - border) * 2, LCARS_CORNER_RADIUS,
			color)
		end
	else
		if vFlip then
			draw.RoundedBox(0,
				border,
				y + LCARS_CORNER_RADIUS,
				(LCARS_CORNER_RADIUS - border) * 2, LCARS_CORNER_RADIUS,
			color)
		else
			draw.RoundedBox(0,
				border,
				y,
				(LCARS_CORNER_RADIUS - border) * 2, LCARS_CORNER_RADIUS,
			color)
		end
	end

	local xLS, yLS, wLS, hLS = 0, 0, 0, 0

	-- Long Strip
	if hFlip then
		xLS = border
		wLS = width - border - LCARS_CORNER_RADIUS
	else
		xLS = LCARS_CORNER_RADIUS - border
		wLS = width - (LCARS_CORNER_RADIUS - border)
	end

	if vFlip then
		yLS = y + border
		hLS = LCARS_STRIP_HEIGHT - border * 2
	else
		yLS = y + (LCARS_CORNER_RADIUS - border) * 2 - (LCARS_STRIP_HEIGHT - border) + border * 2
		hLS = LCARS_STRIP_HEIGHT - border * 2
	end

	if holeSize > 0 then
		local xLS1, xLS2, wLS1, wLS2 = 0, 0, 0, 0
		if hFlip then
			xLS1 = xLS
			xLS2 = xLS + wLS * 0.05 + holeSize

			wLS1 = wLS * 0.05 - border * 2
			wLS2 = wLS * 0.95 - holeSize
		else
			xLS1 = xLS

			wLS1 = wLS * 0.95 - holeSize
			wLS2 = wLS * 0.05 - border * 2

			xLS2 = xLS1 + wLS - wLS2 - border
		end

		draw.RoundedBox(0,
			xLS1,
			yLS,
			wLS1,
			hLS,
		color)

		draw.RoundedBox(0,
			xLS2,
			yLS,
			wLS2,
			hLS,
		color)
	else
		draw.RoundedBox(0,
			xLS,
			yLS,
			wLS,
			hLS,
		color)
	end

	render.ClearStencil()
	render.SetStencilWriteMask(255)
	render.SetStencilTestMask(255)
	render.SetStencilReferenceValue(255)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)

	-- Inner Circle
	render.SetStencilEnable(true)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		if hFlip then
			if vFlip then
				Star_Trek.LCARS:DrawCircle(
					width - (LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS),
					y + LCARS_STRIP_HEIGHT + LCARS_INNER_RADIUS,
					LCARS_INNER_RADIUS + border, 16,
				Color(0, 0, 0, 1))
			else
				Star_Trek.LCARS:DrawCircle(
					width - (LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS),
					y + LCARS_CORNER_RADIUS * 2 - LCARS_STRIP_HEIGHT - LCARS_INNER_RADIUS,
					LCARS_INNER_RADIUS + border, 16,
				Color(0, 0, 0, 1))
			end
		else
			if vFlip then
				Star_Trek.LCARS:DrawCircle(
					LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS,
					y + LCARS_STRIP_HEIGHT + LCARS_INNER_RADIUS,
					LCARS_INNER_RADIUS + border, 16,
				Color(0, 0, 0, 1))
			else
				Star_Trek.LCARS:DrawCircle(
					LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS,
					y + LCARS_CORNER_RADIUS * 2 - LCARS_STRIP_HEIGHT - LCARS_INNER_RADIUS,
					LCARS_INNER_RADIUS + border, 16,
				Color(0, 0, 0, 1))
			end
		end
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
		if hFlip then
			if vFlip then
				draw.RoundedBox(0,
					width - (LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS),
					y + LCARS_STRIP_HEIGHT - LCARS_BORDER_WIDTH,
					LCARS_CORNER_RADIUS + LCARS_INNER_RADIUS, LCARS_INNER_RADIUS + border,
				color)
			else
				draw.RoundedBox(0,
					width - (LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS),
					y + LCARS_CORNER_RADIUS * 2 - LCARS_STRIP_HEIGHT - LCARS_INNER_RADIUS,
					LCARS_CORNER_RADIUS + LCARS_INNER_RADIUS, LCARS_INNER_RADIUS + border,
				color)
			end
		else
			if vFlip then
				draw.RoundedBox(0,
					LCARS_CORNER_RADIUS,
					y + LCARS_STRIP_HEIGHT - LCARS_BORDER_WIDTH,
					LCARS_CORNER_RADIUS + LCARS_INNER_RADIUS, LCARS_INNER_RADIUS + border,
				color)
			else
				draw.RoundedBox(0,
					LCARS_CORNER_RADIUS,
					y + LCARS_CORNER_RADIUS * 2 - LCARS_STRIP_HEIGHT - LCARS_INNER_RADIUS,
					LCARS_CORNER_RADIUS + LCARS_INNER_RADIUS, LCARS_INNER_RADIUS + border,
				color)
			end
		end
	render.SetStencilEnable(false)
end

-- Draw a colored LCARS frame border with a outline.
--
-- @param Number y
-- @param Number width
-- @param Color color
-- @param Boolean hFlip
function Star_Trek.LCARS:DrawFrameBorder(y, width, color, vFlip, hFlip, holeSize)
	Star_Trek.LCARS:DrawFrameBorderShape(y, width, 0, Star_Trek.LCARS.ColorBlack, vFlip, hFlip, holeSize)
	Star_Trek.LCARS:DrawFrameBorderShape(y, width, LCARS_BORDER_WIDTH,     color, vFlip, hFlip, holeSize)
end

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

function Star_Trek.LCARS:DrawInvertedFrame(width, height, title, titleShort, color1, color2, hFlip)
	local titleUpper = string.upper(title)

	surface.SetFont("LCARSMed")
	local textWidth = surface.GetTextSize(titleUpper)

	Star_Trek.LCARS:DrawFrameBorder(0, width, color1, true, hFlip, textWidth + 2)
	Star_Trek.LCARS:DrawFrameBorder(height - LCARS_CORNER_RADIUS * 2, width, color2, false, hFlip)

	if hFlip then
		draw.SimpleText(titleUpper, "LCARSMed", width * 0.05 - LCARS_BORDER_WIDTH, -4, nil, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	else
		draw.SimpleText(titleUpper, "LCARSMed", width * 0.95 - 1, -4, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	end

	local posOffset = 0
	if hFlip then
		posOffset = width - LCARS_CORNER_RADIUS * 2
	end

	local frameStartOffset = LCARS_CORNER_RADIUS * 2
	local remainingHeight = height - frameStartOffset - LCARS_CORNER_RADIUS * 2

	draw.RoundedBox(0,
		posOffset,
		frameStartOffset,
		LCARS_CORNER_RADIUS * 2, remainingHeight,
	Star_Trek.LCARS.ColorBlack)

	draw.RoundedBox(0,
		posOffset + LCARS_BORDER_WIDTH,
		frameStartOffset + LCARS_BORDER_WIDTH,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
	color1)

	draw.RoundedBox(0,
		posOffset + LCARS_BORDER_WIDTH,
		frameStartOffset + LCARS_BORDER_WIDTH + remainingHeight / 2,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
	color2)

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
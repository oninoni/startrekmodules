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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--   LCARS Frame Elements | Client   --
---------------------------------------

local LCARS_CORNER_RADIUS = 25
local LCARS_INNER_RADIUS = 15
local LCARS_FRAME_OFFSET = 4
local LCARS_BORDER_WIDTH = 2
local LCARS_STRIP_HEIGHT = 20

-- Draw a part of the framed spacer.
--
-- @param Number y
-- @param Number width
-- @param Number border
-- @param Boolean vFlip
-- @param Boolean hFlip
-- @param Color color
function Star_Trek.LCARS:DrawFrameSpacePart(y, width, border, vFlip, hFlip, color)
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

	-- Flat Piece
	if hFlip then
		if vFlip then
			draw.RoundedBox(0,
				width - (LCARS_CORNER_RADIUS) * 2 + border,
				y + LCARS_CORNER_RADIUS,
				(LCARS_CORNER_RADIUS - border) * 2, LCARS_CORNER_RADIUS,
			color)
		else
			draw.RoundedBox(0,
				width - (LCARS_CORNER_RADIUS) * 2 + border,
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

	-- Long Strip
	if hFlip then
		if vFlip then
			draw.RoundedBox(0,
				0,
				y + border,
				width - (LCARS_CORNER_RADIUS - border), LCARS_STRIP_HEIGHT - border * 2,
			color)
		else
			draw.RoundedBox(0,
				0,
				y + (LCARS_CORNER_RADIUS - border) * 2 - (LCARS_STRIP_HEIGHT - border) + border * 2,
				width - (LCARS_CORNER_RADIUS - border), LCARS_STRIP_HEIGHT - border * 2,
			color)
		end
	else
		if vFlip then
			draw.RoundedBox(0,
				LCARS_CORNER_RADIUS - border,
				y + border,
				width - (LCARS_CORNER_RADIUS - border), LCARS_STRIP_HEIGHT - border * 2,
			color)
		else
			draw.RoundedBox(0,
				LCARS_CORNER_RADIUS - border,
				y + (LCARS_CORNER_RADIUS - border) * 2 - (LCARS_STRIP_HEIGHT - border) + border * 2,
				width - (LCARS_CORNER_RADIUS - border), LCARS_STRIP_HEIGHT - border * 2,
			color)
		end
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

-- Draws a frame spacer.
--
-- @param Number y
-- @param Number width
-- @param Color top_color
-- @param Color bottom_color
-- @param Boolean hFlip
function Star_Trek.LCARS:DrawFrameSpacer(y, width, top_color, bottom_color, hFlip)
	Star_Trek.LCARS:DrawFrameSpacePart(y, width, 0, false, hFlip, Star_Trek.LCARS.ColorBlack)
	Star_Trek.LCARS:DrawFrameSpacePart(y, width, LCARS_BORDER_WIDTH, false, hFlip, top_color)

	Star_Trek.LCARS:DrawFrameSpacePart(y + LCARS_CORNER_RADIUS * 2 + LCARS_FRAME_OFFSET, width, 0, true, hFlip, Star_Trek.LCARS.ColorBlack)
	Star_Trek.LCARS:DrawFrameSpacePart(y + LCARS_CORNER_RADIUS * 2 + LCARS_FRAME_OFFSET, width, LCARS_BORDER_WIDTH, true, hFlip, bottom_color)
end

function Star_Trek.LCARS:DrawFrame(width, height, title, titleShort, color1, color2, color3, hFlip)
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

function Star_Trek.LCARS:CreateFrame(id, width, height, title, titleShort, color1, color2, color3, hFlip, height2, color4)
	return Star_Trek.LCARS:CreateMaterial("Frame_" .. id, width, height, function()
		color1 = color1 or table.Random(Star_Trek.LCARS.Colors)
		color2 = color2 or table.Random(Star_Trek.LCARS.Colors)
		color3 = color3 or table.Random(Star_Trek.LCARS.Colors)
		color4 = color4 or table.Random(Star_Trek.LCARS.Colors)

		if isnumber(height2) then
			Star_Trek.LCARS:DrawDoubleFrame(width, height, title, titleShort, color1, color2, color3, height2, color4, hFlip)
		else
			Star_Trek.LCARS:DrawFrame(width, height, title, titleShort, color1, color2, color3, hFlip)
		end
	end)
end

-- Renders the given Frame.
--
-- @param Table materialData
function Star_Trek.LCARS:RenderFrame(materialData)
	surface.SetMaterial(materialData.Material)

	surface.DrawTexturedRectUV(-materialData.Width / 2, -materialData.Height / 2, materialData.Width, materialData.Height, 0, 0, materialData.U, materialData.V)
end
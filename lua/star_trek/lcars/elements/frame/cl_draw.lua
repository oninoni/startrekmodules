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

-- LCARS Design Parameters
local LCARS_CORNER_RADIUS = 30
local LCARS_INNER_RADIUS = 15
local LCARS_BORDER_WIDTH = 2
local LCARS_STRIP_HEIGHT = 15

function SELF:DrawSweptShape(x, y, width, border, color, hFlip, vFlip, holeSize)
	holeSize = holeSize or 0

	-- Outer Circle
	if hFlip then
		Star_Trek.LCARS:DrawCircle(
			x + width - LCARS_CORNER_RADIUS,
			y + LCARS_CORNER_RADIUS,
			LCARS_CORNER_RADIUS - border, 32,
		color)
	else
		Star_Trek.LCARS:DrawCircle(
			x + LCARS_CORNER_RADIUS,
			y + LCARS_CORNER_RADIUS,
			LCARS_CORNER_RADIUS - border, 32,
		color)
	end

	-- Flat Piece (Below Rounded Part)
	if hFlip then
		if vFlip then
			draw.RoundedBox(0,
				x + width - LCARS_CORNER_RADIUS * 2 + border,
				y + LCARS_CORNER_RADIUS,
				(LCARS_CORNER_RADIUS - border) * 2, LCARS_CORNER_RADIUS,
			color)
		else
			draw.RoundedBox(0,
				x + width - LCARS_CORNER_RADIUS * 2 + border,
				y,
				(LCARS_CORNER_RADIUS - border) * 2, LCARS_CORNER_RADIUS,
			color)
		end
	else
		if vFlip then
			draw.RoundedBox(0,
				x + border,
				y + LCARS_CORNER_RADIUS,
				(LCARS_CORNER_RADIUS - border) * 2, LCARS_CORNER_RADIUS,
			color)
		else
			draw.RoundedBox(0,
				x + border,
				y,
				(LCARS_CORNER_RADIUS - border) * 2, LCARS_CORNER_RADIUS,
			color)
		end
	end

	local xLS, yLS, wLS, hLS = 0, 0, 0, 0

	-- Long Strip
	if hFlip then
		xLS = x + border
	else
		xLS = x + LCARS_CORNER_RADIUS
	end

	if vFlip then
		yLS = y + border
	else
		yLS = y + (LCARS_CORNER_RADIUS - border) * 2 - (LCARS_STRIP_HEIGHT - border) + border * 2
	end

	wLS = width - border - LCARS_CORNER_RADIUS
	hLS = LCARS_STRIP_HEIGHT - border * 2

	if holeSize > 0 then
		local xLS1, xLS2, wLS1, wLS2 = 0, 0, 0, 0
		if hFlip then
			xLS1 = xLS

			wLS1 = math.ceil(wLS * 0.05)  - border * 2
			wLS2 = math.floor(wLS * 0.95) - holeSize
		else
			xLS1 = xLS

			wLS1 = math.floor(wLS * 0.95) - holeSize
			wLS2 = math.ceil(wLS * 0.05)  - border * 2
		end

		xLS2 = xLS1 + wLS1 + holeSize + border * 2

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
					x + width - (LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS),
					y + LCARS_STRIP_HEIGHT + LCARS_INNER_RADIUS,
					LCARS_INNER_RADIUS + border, 32,
				Color(0, 0, 0, 1))
			else
				Star_Trek.LCARS:DrawCircle(
					x + width - (LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS),
					y + LCARS_CORNER_RADIUS * 2 - LCARS_STRIP_HEIGHT - LCARS_INNER_RADIUS,
					LCARS_INNER_RADIUS + border, 32,
				Color(0, 0, 0, 1))
			end
		else
			if vFlip then
				Star_Trek.LCARS:DrawCircle(
					x + LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS,
					y + LCARS_STRIP_HEIGHT + LCARS_INNER_RADIUS,
					LCARS_INNER_RADIUS + border, 32,
				Color(0, 0, 0, 1))
			else
				Star_Trek.LCARS:DrawCircle(
					x + LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS,
					y + LCARS_CORNER_RADIUS * 2 - LCARS_STRIP_HEIGHT - LCARS_INNER_RADIUS,
					LCARS_INNER_RADIUS + border, 32,
				Color(0, 0, 0, 1))
			end
		end
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
		if hFlip then
			if vFlip then
				draw.RoundedBox(0,
					x + width - (LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS),
					y + LCARS_STRIP_HEIGHT - LCARS_BORDER_WIDTH,
					LCARS_CORNER_RADIUS + LCARS_INNER_RADIUS, LCARS_INNER_RADIUS + border,
				color)
			else
				draw.RoundedBox(0,
					x + width - (LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS),
					y + LCARS_CORNER_RADIUS * 2 - LCARS_STRIP_HEIGHT - LCARS_INNER_RADIUS,
					LCARS_CORNER_RADIUS + LCARS_INNER_RADIUS, LCARS_INNER_RADIUS + border,
				color)
			end
		else
			if vFlip then
				draw.RoundedBox(0,
					x + LCARS_CORNER_RADIUS,
					y + LCARS_STRIP_HEIGHT - LCARS_BORDER_WIDTH,
					LCARS_CORNER_RADIUS + LCARS_INNER_RADIUS, LCARS_INNER_RADIUS + border,
				color)
			else
				draw.RoundedBox(0,
					x + LCARS_CORNER_RADIUS,
					y + LCARS_CORNER_RADIUS * 2 - LCARS_STRIP_HEIGHT - LCARS_INNER_RADIUS,
					LCARS_CORNER_RADIUS + LCARS_INNER_RADIUS, LCARS_INNER_RADIUS + border,
				color)
			end
		end
	render.SetStencilEnable(false)
end

function SELF:DrawSwept(x, y, width, color, hFlip, vFlip, holeSize)
	self:DrawSweptShape(x, y, width,                  0, Star_Trek.LCARS.ColorBlack, hFlip, vFlip, holeSize)
	self:DrawSweptShape(x, y, width, LCARS_BORDER_WIDTH,                      color, hFlip, vFlip, holeSize)
end

function SELF:DrawFrame(x, y, width, height, color1, color2, title, titleShort, hFlip)
	local titleUpper = string.upper(title)

	surface.SetFont("LCARSMed")
	local textWidth = surface.GetTextSize(titleUpper)

	self:DrawSwept(x, y                                   , width, color1, hFlip,  true, textWidth + 2)
	self:DrawSwept(x, y + height - LCARS_CORNER_RADIUS * 2, width, color2, hFlip, false)

	if hFlip then
		draw.SimpleText(titleUpper, "LCARSMed", x + math.ceil(width * 0.05) - LCARS_BORDER_WIDTH + 1, y - 3, nil, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	else
		draw.SimpleText(titleUpper, "LCARSMed", x + math.floor(width * 0.95)                     + 1, y - 3, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	end

	local posOffset = 0
	if hFlip then
		posOffset = width - LCARS_CORNER_RADIUS * 2
	end

	local frameStartOffset = LCARS_CORNER_RADIUS * 2
	local remainingHeight = height - frameStartOffset - LCARS_CORNER_RADIUS * 2

	draw.RoundedBox(0,
		x + posOffset,
		y + frameStartOffset,
		LCARS_CORNER_RADIUS * 2, remainingHeight,
	Star_Trek.LCARS.ColorBlack)

	draw.RoundedBox(0,
		x + posOffset + LCARS_BORDER_WIDTH,
		y + frameStartOffset + LCARS_BORDER_WIDTH,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
	color1)

	draw.RoundedBox(0,
		x + posOffset + LCARS_BORDER_WIDTH,
		y + frameStartOffset + LCARS_BORDER_WIDTH + remainingHeight / 2,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
	color2)

	draw.SimpleText(titleShort, "LCARSSmall", x + posOffset + LCARS_CORNER_RADIUS, y + frameStartOffset, Star_Trek.LCARS.ColorBlack, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end
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
--        LCARS Util | Client        --
---------------------------------------

-- Calculate the ammount of scroll/offset of a button list.
--
-- @param Number listOffset
-- @param Number listHeight
-- @param Number buttonCount
-- @param Number mouseYPos
-- @return Number offset
function Star_Trek.LCARS:GetButtonOffset(listOffset, listHeight, buttonCount, mouseYPos)
	local maxCount = math.floor(listHeight / 35) - 1

	local offset = listOffset
	if buttonCount > maxCount then
		local overFlow = math.min(0, listHeight - buttonCount * 35 + 4)

		local relativePos = (mouseYPos - (listOffset + 35)) / (listHeight - 70)
		offset = listOffset + relativePos * overFlow

		offset = math.min(offset, listOffset)
		offset = math.max(offset, listOffset + overFlow)
	end

	return offset
end

-- Generates the offset of a single button.
-- @param Number listHeight
-- @param Number i
-- @param Number buttonCount
-- @param Number offset
-- @return Number yPos
function Star_Trek.LCARS:GetButtonYPos(listHeight, i, buttonCount, offset)
	local y = (i - 1) * 35 + offset

	return y
end

local LCARS_CORNER_RADIUS = 25
local LCARS_INNER_RADIUS = 15
local LCARS_FRAME_OFFSET = 4
local LCARS_BORDER_WIDTH = 2
local LCARS_STRIP_HEIGHT = 20

-- Drawing a normal LCARS panel. (2D Rendering Context)
-- TODO: Redo with pre-render functionality.
--
-- @param Number x
-- @param Number y
-- @param Number width
-- @param Number height
-- @param Color color
-- @param Number alpha
-- @param? Vector pos
function Star_Trek.LCARS:DrawButtonGraphic(x, y, width, height, color, alpha, pos)
	local lcars_white = Color(255, 255, 255, alpha)
	local lcars_black = Color(0, 0, 0, alpha)

	color = ColorAlpha(color, alpha)

	local selected = false
	if isvector(pos) and pos.x >= (x -1) and pos.x <= (x + width) and pos.y >= (y -1) and pos.y <= (y + height) then
		selected = true
	end

	draw.RoundedBox(16, x -1, y -1, width, height, selected and lcars_white or lcars_black)
	draw.RoundedBox(15, x, y, width -2, height -2, color)
end

-- Drawing a normal LCARS panel button. (2D Rendering Context)
-- TODO: Redo with pre-render functionality.
--
-- @param Number x
-- @param Number y
-- @param Number width (min 300)
-- @param Text text
-- @param Color color
-- @param? String s
-- @param? String l
-- @param Number alpha
-- @param? Vector pos
function Star_Trek.LCARS:DrawButton(x, y, width, text, color, s, l, alpha, pos)
	local lcars_black = Color(0, 0, 0, alpha)
	color = ColorAlpha(color, alpha)

	local widthDiff = math.max(0, width - 300)
	local widthOffset = widthDiff / 2

	self:DrawButtonGraphic(x -123 -widthOffset, y, 240 + widthDiff, 32, color, alpha, pos)
	draw.RoundedBox(0, -100 + x - widthOffset, y, 10, 30, lcars_black)
	draw.RoundedBox(0, 55 + x + widthOffset, y, 15, 30, lcars_black)
	draw.RoundedBox(0, 0 + x + widthOffset, y, 45, 30, lcars_black)

	s = s or ""
	l = l or ""

	if #s == 1 then
		draw.DrawText(s, "LCARSBig", 21 + x + widthOffset, y - 4, color, TEXT_ALIGN_LEFT)
	else
		draw.DrawText(s, "LCARSBig", 3 + x + widthOffset, y - 4, color, TEXT_ALIGN_LEFT)
	end

	draw.DrawText(text, "LCARSText", -88 + x - widthOffset, y + 14, lcars_black, TEXT_ALIGN_LEFT)
	draw.DrawText(l, "LCARSSmall", 71 + x + widthOffset, y + 18, lcars_black, TEXT_ALIGN_LEFT)
end

-- Drawing a circle using the given ammount of segments.
--
-- @param Number x
-- @param Number y
-- @param Number radius
-- @param Number seg
-- @param Color color
function Star_Trek.LCARS:DrawCircle(x, y, radius, seg, color)
	local cir = {}

	table.insert(cir, {x = x, y = y})
	for i = 0, seg do
		local arc = math.rad((i / seg) * -360)
		table.insert(cir, {x = x + math.sin( arc ) * radius, y = y + math.cos( arc ) * radius})
	end
	table.insert(cir, {x = x, y = y})

	surface.SetDrawColor(color)
	draw.NoTexture()
	surface.DrawPoly(cir)
end

-- Draw a part of the framed spacer.
--
-- @param Number y
-- @param Number width
-- @param Number border
-- @param Boolean flip
-- @param Color color
function Star_Trek.LCARS:DrawFrameSpacePart(y, width, border, flip, color)
	-- Outer Circle
	Star_Trek.LCARS:DrawCircle(
		LCARS_CORNER_RADIUS,
		y + LCARS_CORNER_RADIUS,
		LCARS_CORNER_RADIUS - border, 16,
	color)

	-- Flat Piece
	if flip then
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

	-- Long Strip
	if flip then
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

	render.ClearStencil()
	render.SetStencilWriteMask(255)
	render.SetStencilTestMask(255)
	render.SetStencilReferenceValue(255)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)

	-- Inner Circle
	render.SetStencilEnable(true)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		if flip then
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

		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
		if flip then
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
	render.SetStencilEnable(false)
end

-- Draws a frame spacer.
--
-- @param Number y
-- @param Number width
-- @param Color top_color
-- @param Color bottom_color
function Star_Trek.LCARS:DrawFrameSpacer(y, width, top_color, bottom_color)
	Star_Trek.LCARS:DrawFrameSpacePart(y, width, 0, false, Star_Trek.LCARS.ColorBlack)
	Star_Trek.LCARS:DrawFrameSpacePart(y, width, LCARS_BORDER_WIDTH, false, top_color)

	Star_Trek.LCARS:DrawFrameSpacePart(y + LCARS_CORNER_RADIUS * 2 + LCARS_FRAME_OFFSET, width, 0, true, Star_Trek.LCARS.ColorBlack)
	Star_Trek.LCARS:DrawFrameSpacePart(y + LCARS_CORNER_RADIUS * 2 + LCARS_FRAME_OFFSET, width, LCARS_BORDER_WIDTH, true, bottom_color)
end

function Star_Trek.LCARS:DrawFrame(width, height, title, titleShort, color1, color2, color3)
	Star_Trek.LCARS:DrawFrameSpacer(0, width, color1, color2)
	draw.SimpleText(title, "LCARSMed", width * 0.95, 3, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

	local frameStartOffset = LCARS_CORNER_RADIUS * 4 + LCARS_FRAME_OFFSET
	local remainingHeight = height - frameStartOffset

	draw.RoundedBox(0,
		0,
		frameStartOffset,
		LCARS_CORNER_RADIUS * 2, remainingHeight,
	Star_Trek.LCARS.ColorBlack)

	draw.RoundedBox(0,
		LCARS_BORDER_WIDTH,
		frameStartOffset + LCARS_BORDER_WIDTH,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
	color2)

	draw.RoundedBox(0,
		LCARS_BORDER_WIDTH,
		frameStartOffset + LCARS_BORDER_WIDTH + remainingHeight / 2,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
	color3)

	draw.SimpleText(titleShort, "LCARSSmall", LCARS_CORNER_RADIUS, frameStartOffset, Star_Trek.LCARS.ColorBlack, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

function Star_Trek.LCARS:DrawDoubleFrame(width, height, title, titleShort, color1, color2, color3, height2, color4)
	Star_Trek.LCARS:DrawFrameSpacer(0, width, color1, color2)
	draw.SimpleText(title, "LCARSMed", width * 0.95, 3, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

	local topFrameStartOffset = LCARS_CORNER_RADIUS * 4 + LCARS_FRAME_OFFSET

	draw.RoundedBox(0,
		0,
		topFrameStartOffset,
		LCARS_CORNER_RADIUS * 2, height2 - topFrameStartOffset,
	Star_Trek.LCARS.ColorBlack)

	draw.RoundedBox(0,
		LCARS_BORDER_WIDTH,
		topFrameStartOffset + LCARS_BORDER_WIDTH,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, height2 - topFrameStartOffset - LCARS_BORDER_WIDTH,
	color2)

	Star_Trek.LCARS:DrawFrameSpacer(height2, width, color2, color3)

	local bottomFrameStarOffset = height2 + topFrameStartOffset
	local remainingHeight = height - bottomFrameStarOffset

	draw.RoundedBox(0,
		0,
		bottomFrameStarOffset,
		LCARS_CORNER_RADIUS * 2, remainingHeight,
	Star_Trek.LCARS.ColorBlack)

	draw.RoundedBox(0,
		LCARS_BORDER_WIDTH,
		bottomFrameStarOffset + LCARS_BORDER_WIDTH,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
	color3)

	draw.RoundedBox(0,
		LCARS_BORDER_WIDTH,
		bottomFrameStarOffset + LCARS_BORDER_WIDTH + remainingHeight / 2,
		LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
	color4)

	draw.SimpleText(titleShort, "LCARSSmall", LCARS_CORNER_RADIUS, topFrameStartOffset, Star_Trek.LCARS.ColorBlack, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

local function filterSize(value)
	return 2 ^ math.ceil(math.log(value) / math.log(2))
end

function Star_Trek.LCARS:CreateFrame(id, width, height, title, titleShort, color1, color2, color3, height2, color4)
	tWidth = filterSize(width)
	tHeight = filterSize(height)

	color1 = color1 or table.Random(Star_Trek.LCARS.Colors)
	color2 = color2 or table.Random(Star_Trek.LCARS.Colors)
	color3 = color3 or table.Random(Star_Trek.LCARS.Colors)
	color4 = color4 or table.Random(Star_Trek.LCARS.Colors)

	local textureName = "LCARS_Frame_" .. id .. "_" .. tWidth .. "x" .. tHeight
	local texture = GetRenderTarget(textureName, tWidth, tHeight)

	local oldW, oldH = ScrW(), ScrH()
	render.SetViewPort(0, 0, tWidth, tHeight)

	render.PushRenderTarget(texture)
	cam.Start2D()
		render.Clear(0, 0, 0, 0, true, true)

		if isnumber(height2) then
			Star_Trek.LCARS:DrawDoubleFrame(width, height, title, titleShort, color1, color2, color3, height2, color4)
		else
			Star_Trek.LCARS:DrawFrame(width, height, title, titleShort, color1, color2, color3)
		end
	cam.End2D()
	render.PopRenderTarget()

	render.SetViewPort(0, 0, oldW, oldH)

	local material = CreateMaterial(textureName, "UnlitGeneric", {
		["$basetexture"] = texture:GetName(),
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
	})
	customMaterial = material

	local materialData = {
		Material = material,
		U = width / tWidth,
		V = height / tHeight,
	}

	return materialData
end

function Star_Trek.LCARS:RenderMaterial(x, y, w, h, materialData)
	surface.SetMaterial(materialData.Material)
	surface.DrawTexturedRectUV(x, y, w, h, 0, 0, materialData.U, materialData.V)
end
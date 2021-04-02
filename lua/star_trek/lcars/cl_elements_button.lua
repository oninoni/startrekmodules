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
--   LCARS Button Elements | Client  --
---------------------------------------

-- Draws a buttons graphic.
--
-- @param Number yOffset
-- @param Number width
-- @param Number height
-- @param Color color
-- @param Color borderColor
-- @param Boolean flatLeft
-- @param Boolean flatRight
function Star_Trek.LCARS:DrawButtonGraphic(yOffset, width, height, color, borderColor, flatLeft, flatRight)
	local solidStart = 0
	local solidWidth = width
	local hd2 = height / 2 

	if not flatLeft then
		solidStart = hd2
		solidWidth = solidWidth - hd2

		Star_Trek.LCARS:DrawCircle(
			hd2,
			yOffset + hd2,
			hd2, 16,
		borderColor)
		
		Star_Trek.LCARS:DrawCircle(
			hd2,
			yOffset + hd2,
			hd2 - 1, 16,
		color)
	end

	if not flatRight then
		solidWidth = solidWidth - hd2
		
		Star_Trek.LCARS:DrawCircle(
			width - hd2,
			yOffset + hd2,
			hd2, 16,
		borderColor)

		Star_Trek.LCARS:DrawCircle(
			width - hd2,
			yOffset + hd2,
			hd2 - 1, 16,
		color)
	end

	draw.RoundedBox(0,
		solidStart,
		yOffset,
		solidWidth, height,
	borderColor)
	
	if flatLeft then
		solidStart = 1
		solidWidth = solidWidth - 1
	end
	if flatRight then
		solidWidth = solidWidth - 1
	end

	draw.RoundedBox(0,
		solidStart,
		yOffset + 1,
		solidWidth, height - 2,
	color)
end

-- Returns the 2digit LCARS Number as a string.
--
-- @param? Number value
-- @return String smallNumber
function Star_Trek.LCARS:GetSmallNumber(value)
	if not (isnumber(value) and value >= 0 and value < 100) then
		value = math.random(0, 99)
	end

	if value < 10 then
		return "0" .. tostring(value)
	else
		return tostring(value)
	end
end

-- Returns the 6digit LCARS Number as a string.
--
-- @param? Number value
-- @return String largeNumber
function Star_Trek.LCARS:GetLargeNumber(value)
	if not (isnumber(value) and value >= 0 and value < 1000000) then
		value = math.random(0, 999999)
	end

	local largeNumber = ""

	if value < 10 then
		largeNumber = "00000" .. tostring(value)
	elseif value < 100 then
		largeNumber = "0000" .. tostring(value)
	elseif value < 1000 then
		largeNumber = "000" .. tostring(value)
	elseif value < 10000 then
		largeNumber = "00" .. tostring(value)
	elseif value < 100000 then
		largeNumber = "0" .. tostring(value)
	else
		largeNumber = tostring(value)
	end

	return string.sub(largeNumber, 1, 2) .. "-" .. string.sub(largeNumber, 3)
end

local BAR_WIDTH = 8

function Star_Trek.LCARS:DrawButton(yOffset, width, height, color, borderColor, text, flatLeft, flatRight, longTextNumber, smallTextNumber)
	Star_Trek.LCARS:DrawButtonGraphic(yOffset, width, height, color, borderColor, flatLeft, flatRight)

	surface.SetFont("LCARSText")
	local textW, _ = surface.GetTextSize(text)
	if width < 200 then
		draw.Text({
			text = text,
			font = "LCARSText",
			pos = {
				width / 2,
				yOffset + height / 2,
			},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = borderColor
		})
	else
		-- Left Bar
		draw.RoundedBoxEx(0,
			height - BAR_WIDTH - 4,
			yOffset,
			BAR_WIDTH,
			height,
		borderColor)

		draw.Text({
			text = text,
			font = "LCARSText",
			pos = {
				height - 2,
				yOffset + height,
			},
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_BOTTOM,
			color = borderColor
		})

		-- Right Small Text
		draw.Text({
			text = longTextNumber,
			font = "LCARSSmall",
			pos = {
				width - 7,
				yOffset + height,
			},
			xalign = TEXT_ALIGN_RIGHT,
			yalign = TEXT_ALIGN_BOTTOM,
			color = borderColor
		})

		-- Right Bar
		draw.RoundedBoxEx(0,
			width - 56,
			yOffset,
			BAR_WIDTH,
			height,
		borderColor)

		-- Big Bar
		draw.RoundedBoxEx(0,
			width - 64 - 40,
			yOffset,
			40,
			height,
		borderColor)

		draw.Text({
			text = smallTextNumber,
			font = "LCARSBig",
			pos = {
				width - 64 - 40 + 1,
				yOffset + height + 5,
			},
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_BOTTOM,
			color = color
		})
	end
end

-- Creates a button with all its states.
-- A button has 6 states: Disabled, Inactive, Active, None, Hovered, ActiveHovered
--
function Star_Trek.LCARS:CreateButton(id, width, height, color, activeColor, text, flatLeft, flatRight, longNumber, smallNumber)
	return Star_Trek.LCARS:CreateMaterial("Button_" .. id, width, height * 6, function()
		local longTextNumber = Star_Trek.LCARS:GetLargeNumber(longNumber)
		print(longNumber, longTextNumber)
		local smallTextNumber = Star_Trek.LCARS:GetSmallNumber(smallNumber)
		print(smallNumber, smallTextNumber)

		Star_Trek.LCARS:DrawButton(0 * height, width, height, Star_Trek.LCARS.ColorGrey, Star_Trek.LCARS.ColorBlack, text, flatLeft, flatRight, longTextNumber, smallTextNumber)
		Star_Trek.LCARS:DrawButton(1 * height, width, height, color                    , Star_Trek.LCARS.ColorBlack, text, flatLeft, flatRight, longTextNumber, smallTextNumber)
		Star_Trek.LCARS:DrawButton(2 * height, width, height, activeColor              , Star_Trek.LCARS.ColorBlack, text, flatLeft, flatRight, longTextNumber, smallTextNumber)
		-- None
		Star_Trek.LCARS:DrawButton(4 * height, width, height, color                    , Star_Trek.LCARS.ColorWhite, text, flatLeft, flatRight, longTextNumber, smallTextNumber)
		Star_Trek.LCARS:DrawButton(5 * height, width, height, activeColor              , Star_Trek.LCARS.ColorWhite, text, flatLeft, flatRight, longTextNumber, smallTextNumber)
	end)
end

function Star_Trek.LCARS:RenderButton(x, y, materialData, state)
	surface.SetMaterial(materialData.Material)

	local vd5 = materialData.V / 6
	surface.DrawTexturedRectUV(x - materialData.Width / 2, y, materialData.Width, materialData.Height / 6, 0, (state - 1) * vd5, materialData.U, state * vd5)
end
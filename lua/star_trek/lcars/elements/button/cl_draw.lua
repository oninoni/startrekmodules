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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--    LCARS Button Element | Draw    --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

-- Draws a buttons graphic.
--
-- @param Number x
-- @param Number y
-- @param Number width
-- @param Number height
-- @param Color color
-- @param Color borderColor
-- @param Boolean flatLeft
-- @param Boolean flatRight
function SELF:DrawButtonGraphic(x, y, width, height, color, borderColor, flatLeft, flatRight)
	local solidStart = 0
	local solidWidth = width
	local hd2 = height / 2

	if not flatLeft then
		solidStart = hd2
		solidWidth = solidWidth - hd2

		Star_Trek.LCARS:DrawCircle(
			x + hd2,
			y + hd2,
			hd2, 16,
		borderColor)

		Star_Trek.LCARS:DrawCircle(
			x + hd2,
			y + hd2,
			hd2 - 1, 16,
		color)
	end

	if not flatRight then
		solidWidth = solidWidth - hd2

		Star_Trek.LCARS:DrawCircle(
			x + width - hd2,
			y + hd2,
			hd2, 16,
		borderColor)

		Star_Trek.LCARS:DrawCircle(
			x + width - hd2,
			y + hd2,
			hd2 - 1, 16,
		color)
	end

	draw.RoundedBox(0,
		x + solidStart,
		y,
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
		x + solidStart,
		y + 1,
		solidWidth, height - 2,
	color)
end

-- Draws a full button.
--
-- @param Number x
-- @param Number y
-- @param Color color
-- @param Color borderColor
-- @param String text
-- @param Boolean flatLeft
-- @param Boolean flatRight
-- @param Number number
-- @param Number barWidth
function SELF:DrawButton(x, y, color, borderColor, text, flatLeft, flatRight, number, barWidth)
	local width = self.ElementWidth
	local height = self.ElementHeight

	self:DrawButtonGraphic(x, y, width, height, color, borderColor, flatLeft, flatRight)

	-- Left Bar
	local xTextPos = x + 4
	if not flatLeft then
		xTextPos = xTextPos + height + barWidth

		draw.RoundedBoxEx(0,
			x + height,
			y + 1,
			barWidth,
			height - 2,
		borderColor)
	end

	draw.Text({
		text = text,
		font = "LCARSText",
		pos = {
			xTextPos,
			y + height,
		},
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_BOTTOM,
		color = Star_Trek.LCARS.ColorBlack
	})

	-- Right Bar
	if not flatRight then
		draw.RoundedBoxEx(0,
			x + width - height - barWidth,
			y + 1,
			barWidth,
			height - 2,
		borderColor)
	end

	if number then
		surface.SetFont("LCARSBig")
		local textWidth = surface.GetTextSize(number)

		-- Big Bar
		local w = textWidth + 2
		local xNumPos = x + width - height - w
		draw.RoundedBoxEx(0,
			xNumPos,
			y + 1,
			w,
			height - 2,
		Star_Trek.LCARS.ColorBlack)

		draw.Text({
			text = number,
			font = "LCARSBig",
			pos = {
				xNumPos + 1,
				y - 3,
			},
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_TOP,
			color = color
		})
	end
end

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
--    LCARS Button Element | Draw    --
---------------------------------------

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

function SELF:DrawButton(x, y, color, borderColor, text, flatLeft, flatRight, longTextNumber, smallTextNumber, barWidth)
	local width = self.ElementWidth
	local height = self.ElementHeight

	self:DrawButtonGraphic(x, y, width, height, color, borderColor, flatLeft, flatRight)

	local textAreaSize = width - height - 56

	surface.SetFont("LCARSText")
	local textW, _ = surface.GetTextSize(text)
	if textW > textAreaSize then
		draw.Text({
			text = text,
			font = "LCARSText",
			pos = {
				x + width / 2,
				y + height / 2,
			},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Star_Trek.LCARS.ColorBlack
		})
	else
		-- Left Bar
		draw.RoundedBoxEx(0,
			x + height - barWidth - 4,
			y + 1,
			barWidth,
			height - 2,
		Star_Trek.LCARS.ColorBlack)

		draw.Text({
			text = text,
			font = "LCARSText",
			pos = {
				x + height - 2,
				y + height,
			},
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_BOTTOM,
			color = Star_Trek.LCARS.ColorBlack
		})

		-- Right Small Text
		draw.Text({
			text = longTextNumber,
			font = "LCARSSmall",
			pos = {
				x + width - 7,
				y + height,
			},
			xalign = TEXT_ALIGN_RIGHT,
			yalign = TEXT_ALIGN_BOTTOM,
			color = Star_Trek.LCARS.ColorBlack
		})

		-- Right Bar
		draw.RoundedBoxEx(0,
			x + width - 56,
			y + 1,
			barWidth,
			height - 2,
		Star_Trek.LCARS.ColorBlack)

		if textW < textAreaSize - 64 then
			-- Big Bar
			draw.RoundedBoxEx(0,
				x + width - 64 - 40,
				y + 1,
				40,
				height - 2,
			Star_Trek.LCARS.ColorBlack)

			draw.Text({
				text = smallTextNumber,
				font = "LCARSBig",
				pos = {
					x + width - 64 - 40 + 1,
					y + height + 5,
				},
				xalign = TEXT_ALIGN_LEFT,
				yalign = TEXT_ALIGN_BOTTOM,
				color = color
			})
		end
	end
end

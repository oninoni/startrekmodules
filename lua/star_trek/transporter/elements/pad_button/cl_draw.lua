---------------------------------------
---------------------------------------
--         Star Trek Modules         --
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

local PADDING = 1

-- Draws an hexaeder at the given position.
--
-- @param Number x
-- @param Number y
-- @param Color color
function SELF:DrawHexaeder(x, y, r, color, border)
	r = r - PADDING

	local hexValues = {}
	for i = 1, 6 do
		local a = math.rad( ( i / 6 ) * -360 )

		hexValues[i] = {
			x = math.sin(a),
			y = math.cos(a),
		}
	end
	table.insert(hexValues, hexValues[1])

	local cX = x + r + PADDING
	local cY = y + r + PADDING

	surface.SetDrawColor(color)
	draw.NoTexture()

	local hex = {{x = cX, y = cY}}
	for _, vert in pairs(hexValues) do
		table.insert( hex, {
			x = cX + (vert.x * (r - border)),
			y = cY + (vert.y * (r - border)),
		})
	end

	surface.DrawPoly(hex)
end

function SELF:DrawCircle(x, y, r, color, border)
	r = r - PADDING - border
	local cX = x + PADDING + border
	local cY = y + PADDING + border

	draw.RoundedBox(r, cX, cY, r * 2, r * 2, color)
end

-- Draws a full button.
--
-- @param Number x
-- @param Number y
-- @param Color color
-- @param Color borderColor
-- @param Boolean round
-- @param Number number
function SELF:DrawPadButton(x, y, color, borderColor, round, number)
	local r = self.ElementWidth / 2

	if round then
		self:DrawCircle(x, y, r, borderColor, 0)
		self:DrawCircle(x, y, r, color, 1)
	else
		self:DrawHexaeder(x, y, r, borderColor, 0)
		self:DrawHexaeder(x, y, r, color, 1)
	end
end
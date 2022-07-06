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
--     LCARS Frame Element | Util    --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

-- Draw the swept shape for LCARS frames.
--
-- @param Number x
-- @param Number y
-- @param Number width
-- @param Number border
-- @param Color color
-- @param? Boolean hFlip
-- @param? Boolean vFlip
-- @param? Number holeSize
function SELF:DrawSweptShape(x, y, width, border, color, hFlip, vFlip, holeSize)
	hFlip = hFlip or false
	vFlip = vFlip or false
	holeSize = holeSize or 0

	-- Outer Circle
	if hFlip then
		Star_Trek.LCARS:DrawCircle(
			x + width - self.CornerRadius,
			y + self.CornerRadius,
			self.CornerRadius - border, 32,
		color)
	else
		Star_Trek.LCARS:DrawCircle(
			x + self.CornerRadius,
			y + self.CornerRadius,
			self.CornerRadius - border, 32,
		color)
	end

	-- Flat Piece (Below Rounded Part)
	if hFlip then
		if vFlip then
			draw.RoundedBox(0,
				x + width - self.CornerRadius * 2 + border,
				y + self.CornerRadius,
				(self.CornerRadius - border) * 2, self.CornerRadius,
			color)
		else
			draw.RoundedBox(0,
				x + width - self.CornerRadius * 2 + border,
				y,
				(self.CornerRadius - border) * 2, self.CornerRadius,
			color)
		end
	else
		if vFlip then
			draw.RoundedBox(0,
				x + border,
				y + self.CornerRadius,
				(self.CornerRadius - border) * 2, self.CornerRadius,
			color)
		else
			draw.RoundedBox(0,
				x + border,
				y,
				(self.CornerRadius - border) * 2, self.CornerRadius,
			color)
		end
	end

	local xLS, yLS, wLS, hLS = 0, 0, 0, 0

	-- Long Strip
	if hFlip then
		xLS = x + border
	else
		xLS = x + self.CornerRadius
	end

	if vFlip then
		yLS = y + border
	else
		yLS = y + (self.CornerRadius - border) * 2 - (self.StripHeight - border) + border * 2
	end

	wLS = width - border - self.CornerRadius
	hLS = self.StripHeight - border * 2

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
					x + width - (self.CornerRadius * 2 + self.InnerRadius),
					y + self.StripHeight + self.InnerRadius,
					self.InnerRadius + border, 32,
				Color(0, 0, 0, 1))
			else
				Star_Trek.LCARS:DrawCircle(
					x + width - (self.CornerRadius * 2 + self.InnerRadius),
					y + self.CornerRadius * 2 - self.StripHeight - self.InnerRadius,
					self.InnerRadius + border, 32,
				Color(0, 0, 0, 1))
			end
		else
			if vFlip then
				Star_Trek.LCARS:DrawCircle(
					x + self.CornerRadius * 2 + self.InnerRadius,
					y + self.StripHeight + self.InnerRadius,
					self.InnerRadius + border, 32,
				Color(0, 0, 0, 1))
			else
				Star_Trek.LCARS:DrawCircle(
					x + self.CornerRadius * 2 + self.InnerRadius,
					y + self.CornerRadius * 2 - self.StripHeight - self.InnerRadius,
					self.InnerRadius + border, 32,
				Color(0, 0, 0, 1))
			end
		end
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
		if hFlip then
			if vFlip then
				draw.RoundedBox(0,
					x + width - (self.CornerRadius * 2 + self.InnerRadius),
					y + self.StripHeight - self.BorderWidth,
					self.CornerRadius + self.InnerRadius, self.InnerRadius + border,
				color)
			else
				draw.RoundedBox(0,
					x + width - (self.CornerRadius * 2 + self.InnerRadius),
					y + self.CornerRadius * 2 - self.StripHeight - self.InnerRadius,
					self.CornerRadius + self.InnerRadius, self.InnerRadius + border,
				color)
			end
		else
			if vFlip then
				draw.RoundedBox(0,
					x + self.CornerRadius,
					y + self.StripHeight - self.BorderWidth,
					self.CornerRadius + self.InnerRadius, self.InnerRadius + border,
				color)
			else
				draw.RoundedBox(0,
					x + self.CornerRadius,
					y + self.CornerRadius * 2 - self.StripHeight - self.InnerRadius,
					self.CornerRadius + self.InnerRadius, self.InnerRadius + border,
				color)
			end
		end
	render.SetStencilEnable(false)
end

-- Draw the swept for LCARS frames.
--
-- @param Number x
-- @param Number y
-- @param Number width
-- @param Color color
-- @param? Boolean hFlip
-- @param? Boolean vFlip
-- @param? Number holeSize
function SELF:DrawSwept(x, y, width, color, hFlip, vFlip, holeSize)
	self:DrawSweptShape(x, y, width,                  0, Star_Trek.LCARS.ColorBlack, hFlip, vFlip, holeSize)
	self:DrawSweptShape(x, y, width, self.BorderWidth,                      color, hFlip, vFlip, holeSize)
end
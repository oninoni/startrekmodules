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
--    LCARS Transport Pad | Client   --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(windowData)
	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.PadRadius = 30
	self.Pads = {}

	self.Scale = 2

	local avPos = Vector()
	local minX, minY =  math.huge,  math.huge
	local maxX, maxY = -math.huge, -math.huge

	for i, pad in pairs(windowData.Pads) do
		local padData = {}
		padData.Disabled = pad.Disabled
		padData.Selected = pad.Selected

		local entIndex = pad.Data
		local ent = ents.GetByIndex(entIndex)
		if not IsValid(ent) then continue end

		local pos = Star_Trek.Transporter:GetPadPosition(ent)

		padData.X = pos.x
		padData.Y = pos.y

		padData.Cargo = Star_Trek.Transporter:IsCargoPad(ent)

		self.Pads[i] = padData

		avPos = avPos + pos
		minX = math.min(minX, pos.x)
		minY = math.min(minY, pos.y)
		maxX = math.max(maxX, pos.x)
		maxY = math.max(maxY, pos.y)
	end

	avPos = Vector(
		math.Round(avPos.x / table.Count(self.Pads), 2),
		math.Round(avPos.y / table.Count(self.Pads), 2),
		0
	)

	minX = minX - avPos.x
	minY = minY - avPos.y
	maxX = maxX - avPos.x
	maxY = maxY - avPos.y
	local xScale = maxX - minX + self.PadRadius * 2
	local yScale = maxY - minY + self.PadRadius * 2
	self.Scale = math.min(
		self.Area1Width  / xScale,
		self.Area1Height / yScale
	) * 0.9
	self.ScaledPadRadius = self.PadRadius * self.Scale

	for id, padData in pairs(self.Pads) do
		padData.X = (-(padData.X - avPos.x) - self.PadRadius) * self.Scale
		padData.Y = ( (padData.Y - avPos.y) - self.PadRadius) * self.Scale

		padData.X = padData.X + self.Area1X + self.Area1Width / 2
		padData.Y = padData.Y + self.Area1Y + self.Area1Height / 2

		local successButton, button = self:GenerateElement("pad_button", self.Id .. "_" .. id, self.ScaledPadRadius * 2, self.ScaledPadRadius * 2,
			id,
			Star_Trek.LCARS.ColorBlue, padData.ActiveColor,
			padData.Cargo,
			padData.Disabled, padData.Selected, false)
		if not successButton then return false end

		padData.Element = button
	end

	return self
end

function SELF:IsPadHovered(x, y, pos)
	if math.Distance(x + self.ScaledPadRadius, y + self.ScaledPadRadius, pos[1], pos[2]) < self.ScaledPadRadius then
		return true
	end

	return false
end

function SELF:OnPress(pos, animPos)
	for i, padData in pairs(self.Pads) do
		if self:IsPadHovered(padData.X, padData.Y, pos) then
			return i
		end
	end
end

function SELF:OnDraw(pos, animPos)
	surface.SetDrawColor(255, 255, 255, 255 * animPos)
	for i, padData in pairs(self.Pads) do
		local x, y = padData.X, padData.Y

		if self.MouseActive then
			padData.Element.Hovered = self:IsPadHovered(x, y, pos)
		else
			padData.Element.Hovered = false
		end

		padData.Element:Render(x, y)
	end

	SELF.Base.OnDraw(self, pos, animPos)
end
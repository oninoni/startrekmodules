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
--    LCARS Transport Pad | Client   --
---------------------------------------


if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(windowData)
	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.Pads = windowData.Pads
	self.PadRadius = self.WHeight / 8

	for id, padData in pairs(self.Pads) do
		local successButton, button = self:GenerateElement("pad_button", self.Id .. "_" .. id, self.PadRadius * 2, self.PadRadius * 2,
			id, 
			Star_Trek.LCARS.ColorBlue, padData.ActiveColor,
			padData.Type == "Round",
			padData.Disabled, padData.Selected, false)
		if not successButton then return false end

		padData.Element = button
	end

	return self
end

function SELF:IsPadHovered(x, y, pos)
	if math.Distance(x + self.PadRadius, y + self.PadRadius, pos[1], pos[2]) < self.PadRadius then
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

		padData.Element.Hovered = self:IsPadHovered(x, y, pos)
		padData.Element:Render(x, y)
	end

	SELF.Base.OnDraw(self, pos, animPos)
end
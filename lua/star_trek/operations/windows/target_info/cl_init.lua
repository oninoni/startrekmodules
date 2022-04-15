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
--     LCARS Target Info | Client    --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(windowData)
	self.Padding = self.Padding or 1
	self.FrameType = self.FrameType or "frame"

	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	-- TODO

	return true
end

function SELF:OnDraw(pos, animPos)
	-- TODO

	local c1 = ColorAlpha(Star_Trek.LCARS.ColorLightBlue, animPos * 255)
	local c2 = ColorAlpha(Star_Trek.LCARS.ColorOrange, animPos * 255)
	local c3 = ColorAlpha(Star_Trek.LCARS.ColorRed, animPos * 255)

	local x1 = self.Area1X
	local x2 = self.Area1X - 2 + self.Area1Width / 2
	local x3 = self.Area1XEnd - 4

	local y1 = self.Area1Y + self.Area1Height * (1 / 4)
	draw.SimpleText("USS Defiant",        "LCARSText", x1, y1, c1, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
	draw.SimpleText("Name | Affiliation", "LCARSText", x2, y1, c1, TEXT_ALIGN_CENTER,  TEXT_ALIGN_CENTER)
	draw.SimpleText("Federation",         "LCARSText", x3, y1, c1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

	local y2 = self.Area1Y + self.Area1Height * (2 / 4)
	draw.SimpleText("100%",            "LCARSText", x1, y2, c2, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
	draw.SimpleText("Power | Shields", "LCARSText", x2, y2, c1, TEXT_ALIGN_CENTER,  TEXT_ALIGN_CENTER)
	draw.SimpleText("100%",            "LCARSText", x3, y2, c2, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)

	local y3 = self.Area1Y + self.Area1Height * (3 / 4)
	draw.SimpleText("Charged",          "LCARSText", x1, y3, c2, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
	draw.SimpleText("Weapons | Target", "LCARSText", x2, y3, c1, TEXT_ALIGN_CENTER,  TEXT_ALIGN_CENTER)
	draw.SimpleText("USS Voyager",      "LCARSText", x3, y3, c3, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)


	SELF.Base.OnDraw(self, pos, animPos)
end
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

	self.Simple = windowData.Simple
	self.TargetId = windowData.TargetId

	return true
end

function SELF:GetTargetInformation(id)
	id = id or self.TargetId

	-- TEMPORARY STUFF
	if id == 0 then
		return {
			Name = "USS Intrepid",
			Faction = "Federation",

			Power = 100,
			Shield = 0,

			Weapons = false,
			TargetId = 0,
		}
	end

	return {
		Name = "USS Defiant",
		Faction = "Federation",

		Power = 100,
		Shield = 100,

		Weapons = false,
		TargetId = 0,
	}
end

function SELF:OnDraw(pos, animPos)
	local c1 = ColorAlpha(Star_Trek.LCARS.ColorLightBlue, animPos * 255)
	local c2 = ColorAlpha(Star_Trek.LCARS.ColorOrange, animPos * 255)
	local c3 = ColorAlpha(Star_Trek.LCARS.ColorRed, animPos * 255)

	local x1 = self.Area1X + 4
	local x2 = self.Area1X + self.Area1Width / 2
	local x3 = self.Area1XEnd - 4

	local targetInformation = self:GetTargetInformation()

	local y2, y3
	if self.Simple then
		y2 = self.Area1Y + self.Area1Height * (0.9 / 3)
		y3 = self.Area1Y + self.Area1Height * (2.1 / 3)
	else
		y2 = self.Area1Y + self.Area1Height * (2 / 4)
		y3 = self.Area1Y + self.Area1Height * (3.2 / 4)

		local y1 = self.Area1Y + self.Area1Height * (0.8 / 4)
		draw.SimpleText(targetInformation.Name,        "LCARSText", x1, y1, c1, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
		draw.SimpleText("Name|", "LCARSText", x2 + 8, y1, c1, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)

		draw.SimpleText("|Faction", "LCARSText", x2 - 8, y1, c1, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
		draw.SimpleText(targetInformation.Faction,         "LCARSText", x3, y1, c1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	draw.SimpleText(targetInformation.Power and targetInformation.Power .. "%" or "Inactive",            "LCARSText", x1, y2, c2, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
	draw.SimpleText("Power|", "LCARSText", x2 + 8, y2, c1, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)

	draw.SimpleText("|Shield", "LCARSText", x2 - 8, y2, c1, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
	draw.SimpleText(targetInformation.Shield and targetInformation.Shield .. "%" or "Inactive",            "LCARSText", x3, y2, c2, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)

	draw.SimpleText(targetInformation.Weapons and targetInformation.Weapons .. "%" or "Inactive",          "LCARSText", x1, y3, c2, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
	draw.SimpleText("Weapon|", "LCARSText", x2 + 8, y3, c1, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)

	local targetWeaponTargetInforamtion = SELF:GetTargetInformation(targetInformation.TargetId)
	draw.SimpleText("|Target", "LCARSText", x2 - 8, y3, c1, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
	draw.SimpleText(targetWeaponTargetInforamtion.Name,      "LCARSText", x3, y3, c3, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)

	SELF.Base.OnDraw(self, pos, animPos)
end
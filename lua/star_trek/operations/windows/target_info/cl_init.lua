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

	self.TargetId = windowData.TargetId
	self.Simple = windowData.Simple
	self.Selector = windowData.Selector

	return true
end

function SELF:GetTargetInformation(id)
	id = id or self.TargetId

	-- TEMPORARY STUFF
	if id == 1 then
		return {
			Name = "USS Intrepid",
			Faction = "Federation",

			Power = 100,
			Shield = 0,

			Weapons = false,
			TargetId = 1,
		}
	end

	return {
		Name = "USS Defiant",
		Faction = "Federation",

		Power = 100,
		Shield = 100,

		Weapons = 0,
		TargetId = 2,
	}
end

function SELF:OnPress(pos, animPos)
	if not self.Selector then
		return
	end

	local x1 = self.Area1X + 4
	local x2 = self.Area1X + self.Area1Width / 2
	local x3 = self.Area1XEnd - 4

	local x = pos.x
	if x > x1 and x < x3 then
		if x > x2 then
			return 1
		else
			return 2
		end
	end
end

function SELF:OnDraw(pos, animPos)
	local x1 = self.Area1X + 4
	local x2 = self.Area1X + self.Area1Width / 2
	local x3 = self.Area1XEnd - 4

	local c1 = ColorAlpha(Star_Trek.LCARS.ColorLightBlue, animPos * 255)
	local c2 = ColorAlpha(Star_Trek.LCARS.ColorOrange, animPos * 255)
	local c3 = ColorAlpha(Star_Trek.LCARS.ColorRed, animPos * 255)
	local c4 = ColorAlpha(Star_Trek.LCARS.ColorWhite, animPos * 255)

	local targetInformation = self:GetTargetInformation()

	local y2, y3
	if self.Simple then
		y2 = self.Area1Y + self.Area1Height * (0.75 / 3)
		y3 = self.Area1Y + self.Area1Height * (2.25 / 3)
	else
		y2 = self.Area1Y + self.Area1Height * (2 / 4)
		y3 = self.Area1Y + self.Area1Height * (3.2 / 4)

		local y1 = self.Area1Y + self.Area1Height * (0.8 / 4)
		draw.SimpleText(targetInformation.Name,        "LCARSText", x1, y1, c1, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
		draw.SimpleText("Name|", "LCARSText", x2 + 8, y1, c1, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)

		draw.SimpleText("|Faction", "LCARSText", x2 - 8, y1, c1, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
		draw.SimpleText(targetInformation.Faction,         "LCARSText", x3, y1, c1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	if self.Selector then
		local xM1 = self.Area1X + self.Area1Width * (2 / 6)
		local xM2 = self.Area1X + self.Area1Width * (4 / 6)

		local cL, cR = c1, c1

		local x = pos.x
		if x > x1 and x < x3 then
			if x > x2 then
				cR = c4
			else
				cL = c4
			end
		end

		draw.SimpleText("<<", "LCARSText", xM1, y2, cL, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)
		draw.SimpleText(">>", "LCARSText", xM2, y2, cR, TEXT_ALIGN_LEFT ,  TEXT_ALIGN_CENTER)
	end

	if tobool(targetInformation.Power) then
		draw.SimpleText(targetInformation.Power .. "%", "LCARSText", x1, y2, c2, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("Offline"                     , "LCARSText", x1, y2, c3, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
	end
	draw.SimpleText("Power|", "LCARSText", x2 + 8, y2, c1, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)

	if tobool(targetInformation.Shield) then
		draw.SimpleText(targetInformation.Shield .. "%", "LCARSText", x3, y2, c2, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("Offline"                      , "LCARSText", x3, y2, c3, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)
	end
	draw.SimpleText("|Shield", "LCARSText", x2 - 8, y2, c1, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)

	if tobool(targetInformation.Weapons) then
		draw.SimpleText(targetInformation.Weapons .. "%", "LCARSText", x1, y3, c2, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("Offline"                       , "LCARSText", x1, y3, c3, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)
	end
	draw.SimpleText("Weapon|", "LCARSText", x2 + 8, y3, c1, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)

	if tobool(targetInformation.TargetId) then
		local targetWeaponTargetInforamtion = SELF:GetTargetInformation(targetInformation.TargetId)

		local c = c2
		if targetInformation.TargetId == 1 then
			c = c3
		end

		draw.SimpleText(targetWeaponTargetInforamtion.Name, "LCARSText", x3, y3, c, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("No Target"                       , "LCARSText", x3, y3, c1, TEXT_ALIGN_RIGHT,  TEXT_ALIGN_CENTER)
	end
	draw.SimpleText("|Target", "LCARSText", x2 - 8, y3, c1, TEXT_ALIGN_LEFT,  TEXT_ALIGN_CENTER)

	SELF.Base.OnDraw(self, pos, animPos)
end
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
--     LCARS Section Map | Client    --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

local MAP_TIME = 20
local MARK_TIME = 4

function SELF:OnCreate(windowData)
	self.Padding = self.Padding or 1
	self.FrameType = self.FrameType or "frame_double"

	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.MapScale = 0.4

	local successMap, mapElement = self:GenerateElement("map", self.Id .. "_", self.Area1Width, self.Area1Height,
		windowData.Sections, Vector(), self.MapScale
	)
	if not successMap then
		return false, mapElement
	end
	self.MapElement = mapElement

	self.Objects = windowData.Objects
	self.LastObjectTime = CurTime()

	return self
end

function SELF:OnDraw(pos, animPos)
	local alpha = 255 * animPos
	surface.SetDrawColor(255, 255, 255, alpha)
	self.MapElement:Render(self.Area1X, self.Area1Y)

	local diff = CurTime() - self.LastObjectTime
	for i, object in pairs(self.Objects) do
		local timeOffset = diff - (i - 1) * 0.2
		if timeOffset > 0 then
			if not object.SoundPlayed then
				EmitSound("star_trek.lcars_beep2", Vector(), self.Interface.Ent:EntIndex())
				object.SoundPlayed = true
			end

			local oPos = object.Pos
			local x = math.floor(oPos[1] * self.MapScale + self.Area1X + self.Area1Width  / 2)
			local y = math.floor(oPos[2] * self.MapScale + self.Area1Y + self.Area1Height / 2)

			if timeOffset < MARK_TIME and not object.HideCross then
				local markAlpha = math.max(0, math.min(1, MARK_TIME - timeOffset)) * alpha

				draw.RoundedBox(0, self.Area1X, y - 1, self.Area1Width, 2, ColorAlpha(Star_Trek.LCARS.ColorLightBlue, markAlpha))
				draw.RoundedBox(0, x - 1, self.Area1Y, 2, self.Area1Height, ColorAlpha(Star_Trek.LCARS.ColorLightBlue, markAlpha))
			end

			local objectAlpha = math.max(0, math.min(1, MAP_TIME - timeOffset)) * alpha
			if object.Big then
				draw.RoundedBox(12, x - 12, y - 12, 24, 24, ColorAlpha(object.Color, objectAlpha))
				draw.RoundedBox(8, x - 8, y - 8, 16, 16, ColorAlpha(Star_Trek.LCARS.ColorOrange, objectAlpha))
				draw.RoundedBox(6, x - 6, y - 6, 12, 12, ColorAlpha(object.Color, objectAlpha))
			else
				draw.RoundedBox(8, x - 8, y - 8, 16, 16, ColorAlpha(object.Color, objectAlpha))
			end

		end
	end

	SELF.Base.OnDraw(self, pos, animPos)
end
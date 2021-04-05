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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--     LCARS Section Map | Client    --
---------------------------------------

local MAP_SCALE = 5
local MAP_OFFSET_X = 0
local MAP_OFFSET_Y = -200

local SELF = WINDOW
function SELF:OnCreate(windowData)
	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.Sections = windowData.Sections

	return self
end

function SELF:OnDraw(pos, animPos)
	cam.End3D2D()
	cam.Start3D2D(self.WPos, self.WAng, 1 / (self.WScale * MAP_SCALE))

	local alpha = 255 * animPos
	local lcars_border = ColorAlpha(Star_Trek.LCARS.ColorLightBlue, alpha)
	local lcars_selected = ColorAlpha(Star_Trek.LCARS.ColorOrange, alpha)
	local lcars_inactive = ColorAlpha(Star_Trek.LCARS.ColorBlue, alpha)

	for _, sectionData in pairs(self.Sections) do
		for _, areaData in pairs(sectionData.Areas) do
			local x = areaData.Pos.x + MAP_OFFSET_X
			local y = areaData.Pos.y + MAP_OFFSET_Y
			local width = areaData.Width
			local height = areaData.Height

			draw.RoundedBox(0, x - 1 * MAP_SCALE, y - 1 * MAP_SCALE, width + 2 * MAP_SCALE, height + 2 * MAP_SCALE, lcars_border)
		end
	end

	for _, sectionData in pairs(self.Sections) do
		for _, areaData in pairs(sectionData.Areas) do
			local x = areaData.Pos.x + MAP_OFFSET_X
			local y = areaData.Pos.y + MAP_OFFSET_Y
			local width = areaData.Width
			local height = areaData.Height

			draw.RoundedBox(0, x, y, width, height, sectionData.Selected and lcars_selected or lcars_inactive)
		end
	end

	cam.End3D2D()
	cam.Start3D2D(self.WPos, self.WAng, 1 / self.WScale)

	SELF.Base.OnDraw(self, pos, animPos)
end
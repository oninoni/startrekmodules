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
--      LCARS Map Element | Draw     --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

-- TODO: Add Offset
-- TODO: Add Scale

function SELF:DrawMap(x, y, color, colorSelected, border)
	local scale = self.Scale or 1

	for _, sectionData in pairs(self.Sections) do
		for _, areaData in pairs(sectionData.Areas) do
			local areaX = (x + areaData.Pos[1]) * scale - border
			local areaY = (y + areaData.Pos[2]) * scale - border
			local areaWidth  = math.ceil(areaData.Width * scale + 2 * border )
			local areaHeight = math.ceil(areaData.Height * scale + 2 * border)

			areaX = math.floor(areaX + self.ElementWidth / 2)
			areaY = math.floor(areaY + self.ElementHeight / 2)
			
			draw.RoundedBox(0, areaX, areaY, areaWidth, areaHeight, sectionData.Selected and colorSelected or color)
		end
	end
end
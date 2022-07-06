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
--      LCARS Replicator | Util      --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

-- Generate the categories and buttons of the replicator.
function SELF:GenerateCategories(ent)
	local categories = Star_Trek.Replicator:GetReplicatorList(ent)
	local categoryCount = #categories

	table.insert(categories, {
		Name = "CLEAN",
		Color = Star_Trek.LCARS.ColorOrange,
		Buttons = {},
	})

	table.insert(categories, {
		Name = "CLOSE",
		Color = Star_Trek.LCARS.ColorRed,
		Buttons = {},
	})

	return categories, categoryCount
end
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
--    LCARS OPS Interface | Server   --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = "base"

-- Opening general purpose menus.
function SELF:Open(ent)
	local success, mapWindow = Star_Trek.LCARS:CreateWindow("system_map",
		Vector(-45, -10, 30), Angle(0, 70, 90),
		15, 600, 600,
		function(windowData, interfaceData, ply, buttonId)
		-- No Interactivity here yet.
	end, systemName, true)
	if not success then
		return false, mapWindow
	end

	return true, {mapWindow}, Vector(), Angle(0, 90, 0)
end
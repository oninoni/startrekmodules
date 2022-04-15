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
	local targetName = "NX-74205 USS Defiant"

	local success1, targetInfoWindow = Star_Trek.LCARS:CreateWindow("target_info",
	Vector(-45.6, -20, 3.6), Angle(0, 71.5, 27),
		nil, 420, 140,
		function(windowData, interfaceData, ply, buttonId)

	end, targetName, false)
	if not success1 then
		return false, targetInfoWindow
	end

	local success2, mapWindow = Star_Trek.LCARS:CreateWindow("system_map",
		Vector(-45, -10, 30), Angle(0, 70, 90),
		15, 600, 600,
		function(windowData, interfaceData, ply, buttonId)
		-- No Interactivity here yet.
	end, systemName, true)
	if not success2 then
		return false, mapWindow
	end

	return true, {targetInfoWindow, mapWindow}, Vector(), Angle(0, 90, 0)
end
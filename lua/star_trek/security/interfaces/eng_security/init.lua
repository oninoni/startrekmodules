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
--    LCARS Engi Security | Server   --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = "bridge_security"

-- Open a security Console
--
-- @param Entity ent
-- @return Boolean success
-- @return? Table windows
function SELF:Open(ent)
	local success, windows = self:OpenInternal(
		Vector(-15.5, -8.1, -14.25),
		Angle(0, 0, 0),
		400,
		Vector(-15.5, 4.1, -14.25),
		Angle(0, 0, 0),
		400,
		false,
		Vector(10, -26.25, 2.5),
		Angle(0, 0, -76.5),
		40,
		1600,
		1200,
		Vector(-20, -26.25, 2.5),
		Angle(0, 0, -76.5),
		400,
		600,
		Vector(8.5, -2, -14.25),
		Angle(0, 0, 0),
		20,
		625,
		478
	)
	if not success then
		return false, windows
	end

	return true, windows
end

-- Wrap for use in Map.
function Star_Trek.LCARS:OpenSecurityEngMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "eng_security")
end
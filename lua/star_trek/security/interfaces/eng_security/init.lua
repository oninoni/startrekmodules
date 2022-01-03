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
function SELF:Open(ent, engineering)
	local success, windows = self:OpenInternal(
		Vector(-12, -8.1, -14.25),
		Angle(0, 0, 0),
		580,
		Vector(-12, 4.1, -14.25),
		Angle(0, 0, 0),
		580,
		false,
		Vector(10, -26.25, 2.5),
		Angle(0, 0, -76.5),
		800,
		600,
		Vector(-20, -26.25, 2.5),
		Angle(0, 0, -76.5),
		400,
		600,
		Vector(12, -2, -14.25),
		Angle(0, 0, 0),
		570,
		570
	)
	if not success then
		return false, windows
	end

	return true, windows, Vector(0, 0, 0), Angle(0, 0, 0)
end

-- Wrap for use in Map.
function Star_Trek.LCARS:OpenSecurityEngMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "eng_security", true)
end
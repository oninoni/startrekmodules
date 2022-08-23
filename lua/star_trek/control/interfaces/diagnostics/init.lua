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
--    LCARS Disagnostics | Server    --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

include("util.lua")

SELF.BaseInterface = "bridge_security"

SELF.LogType = "Diagnostics Console"

function SELF:Open(ent)
	self.Modes = {
		"Diagnostics",
		"Control",
	}

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
		800,
		600,
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
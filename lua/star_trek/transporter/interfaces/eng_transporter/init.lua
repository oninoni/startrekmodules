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
--  LCARS Engi Transporter | Server  --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = "transporter"

SELF.Solid = false

function SELF:Open(ent)
	local success, windows = self:OpenInternal(
		Vector(-12, 4, -14.25),
		Angle(0, 0, 0),
		580,
		Vector(-15, -26.25, 2.5),
		Angle(0, 0, -76.5),
		600,
		600,
		Vector(12, -8, -14.25),
		Angle(0, 0, 0),
		Vector(-12, -8, -14.25),
		Angle(0, 0, 0),
		580,
		280,
		nil
	)
	if not success then
		return false, windows
	end

	return true, windows, Vector(0, 0, 0), Angle(0, 0, 0)
end

function Star_Trek.LCARS:OpenTransporterEngMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "eng_transporter")
end
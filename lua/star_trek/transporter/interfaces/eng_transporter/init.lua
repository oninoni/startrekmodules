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
--  LCARS Engi Transporter | Server  --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = "transporter"

SELF.Solid = false

SELF.AdvancedMode = false

function SELF:Open(ent)
	local success, windows = self:OpenInternal(
		{
			Pos = Vector(-12, 4, -14.25),
			Ang = Angle(0, 0, 0),
			Width = 580,
		},
		{
			Pos = Vector(-15, -26.25, 2.5),
			Ang = Angle(0, 0, -76.5),
			Width = 600, Height = 600,
		},
		{
			Pos = Vector(12, -8, -14.25),
			Ang = Angle(0, 0, 0),
		},
		{
			Pos = Vector(-12, -8, -14.25),
			Ang = Angle(0, 0, 0),
			Width = 580, Height = 280,
		}
	)
	if not success then
		return false, windows
	end

	return true, windows, Vector(0, 0, 0), Angle(0, 0, 0)
end

function Star_Trek.LCARS:OpenTransporterEngMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "eng_transporter")
end
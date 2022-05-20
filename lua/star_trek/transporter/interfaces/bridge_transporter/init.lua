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
-- LCARS Bridge Transporter | Server --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = "transporter"

SELF.Solid = false

SELF.AdvancedMode = false

function SELF:Open(ent)
	local success, windows = self:OpenInternal(
		{
			Pos = Vector(-22, -34, 8.2),
			Ang = Angle(0, 0, -90),
			Width = 500,
		},
		{
			Pos = Vector(-26, -5, -2),
			Ang = Angle(0, 0, 0),
			Width = 550, Height = 720,
		},
		{
			Pos = Vector(0, -34, 8),
			Ang = Angle(0, 0, -90),
		},
		{
			Pos = Vector(0, -0.5, -2),
			Ang = Angle(0, 0, 0),
			Width = 550, Height = 710,
		}
	)
	if not success then
		return false, windows
	end

	return true, windows, Vector(0, 11.5, -4), Angle(0, 0, -8)
end

function Star_Trek.LCARS:OpenConsoleTransporterMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "bridge_transporter")
end
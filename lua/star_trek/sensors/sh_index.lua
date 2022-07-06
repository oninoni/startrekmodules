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
--          Sensors | Index          --
---------------------------------------

Star_Trek:RequireModules()

Star_Trek.Sensors = Star_Trek.Sensors or {}

if SERVER then
	include("sv_sensors.lua")
	include("sv_internal.lua")
end
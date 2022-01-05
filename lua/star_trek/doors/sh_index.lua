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
--           Doors | Index           --
---------------------------------------

Star_Trek:RequireModules()

Star_Trek.Doors = Star_Trek.Doors or {}

if SERVER then
	include("sv_config.lua")
	include("sv_doors.lua")
end
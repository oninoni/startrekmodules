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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--         Turbolift | Index         --
---------------------------------------

Star_Trek.Turbolift = Star_Trek.Turbolift or {}

if SERVER then
	include("sv_config.lua")
	include("sv_doors.lua")
	include("sv_path.lua")
	include("sv_turbolift.lua")
end
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
--         Turbolift | Index         --
---------------------------------------

Star_Trek:RequireModules("util", "lcars")

Star_Trek.Turbolift = Star_Trek.Turbolift or {}

if SERVER then
	AddCSLuaFile("sh_sounds.lua")

	include("sh_sounds.lua")

	include("sv_config.lua")
	include("sv_doors.lua")
	include("sv_path.lua")
	include("sv_turbolift.lua")
end

if CLIENT then
	include("sh_sounds.lua")
end
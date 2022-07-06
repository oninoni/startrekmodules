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
--           Doors | Index           --
---------------------------------------

Star_Trek:RequireModules("sections", "control")

Star_Trek.Doors = Star_Trek.Doors or {}

if SERVER then
	AddCSLuaFile("sh_config.lua")
	AddCSLuaFile("sh_doors.lua")

	include("sh_config.lua")
	include("sh_doors.lua")

	include("sv_doors.lua")
end

if CLIENT then
	include("sh_config.lua")
	include("sh_doors.lua")
end
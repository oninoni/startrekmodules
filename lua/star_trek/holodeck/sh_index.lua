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
--          Holodeck | Index         --
---------------------------------------

Star_Trek:RequireModules("util", "lcars")

Star_Trek.Holodeck = Star_Trek.Holodeck or {}

if SERVER then
	AddCSLuaFile("sh_sounds.lua")

	AddCSLuaFile("cl_holomatter.lua")

	include("sh_sounds.lua")

	include("sv_holodeck.lua")
	include("sv_logs.lua")

	include("sv_holomatter.lua")
end

if CLIENT then
	include("sh_sounds.lua")

	include("cl_holomatter.lua")
end
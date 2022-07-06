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
--        Force Fields | Index       --
---------------------------------------

Star_Trek:RequireModules("sections", "control")

Star_Trek.ForceFields = Star_Trek.ForceFields or {}

if SERVER then
	AddCSLuaFile("sh_config.lua")
	AddCSLuaFile("sh_sounds.lua")
	AddCSLuaFile("sh_forcefields.lua")
	AddCSLuaFile("cl_forcefields.lua")

	include("sh_config.lua")
	include("sh_sounds.lua")
	include("sh_forcefields.lua")
	include("sv_forcefields.lua")
end

if CLIENT then
	include("sh_config.lua")
	include("sh_sounds.lua")
	include("sh_forcefields.lua")
	include("cl_forcefields.lua")
end
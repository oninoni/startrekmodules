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
--          Security | Index         --
---------------------------------------

Star_Trek:RequireModules("sections", "lcars", "doors", "control")

Star_Trek.Security = Star_Trek.Security or {}

if SERVER then
	AddCSLuaFile("sh_config.lua")
	AddCSLuaFile("sh_sounds.lua")
	AddCSLuaFile("sh_force_field.lua")
	AddCSLuaFile("cl_force_field.lua")

	include("sh_config.lua")
	include("sh_sounds.lua")
	include("sh_force_field.lua")
	include("sv_force_field.lua")

	include("sv_sub_consoles.lua")
end

if CLIENT then
	include("sh_config.lua")
	include("sh_sounds.lua")
	include("sh_force_field.lua")
	include("cl_force_field.lua")
end
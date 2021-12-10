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
--          Security | Index         --
---------------------------------------

Star_Trek:RequireModules("sections", "lcars", "doors")

Star_Trek.Security = Star_Trek.Security or {}

if SERVER then
	AddCSLuaFile("sh_sounds.lua")
	include("sh_sounds.lua")

	include("sv_force_field.lua")
end

if CLIENT then
	include("sh_sounds.lua")
end
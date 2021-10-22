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
--          Sections | Index         --
---------------------------------------

Star_Trek:RequireModules("util")

Star_Trek.Sections = Star_Trek.Sections or {}

if CLIENT then
	include("cl_sections.lua")
end

if SERVER then
	include("sv_config.lua")
	include("sv_sections.lua")

	AddCSLuaFile("cl_sections.lua")
end
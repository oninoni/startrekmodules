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
--        Transporter | Index        --
---------------------------------------

Star_Trek:RequireModules("util", "sections", "lcars")

Star_Trek.Transporter = Star_Trek.Transporter or {}

if SERVER then
	AddCSLuaFile("sh_sounds.lua")
	AddCSLuaFile("sh_particles.lua")
	AddCSLuaFile("cl_transporter.lua")

	include("sh_sounds.lua")
	include("sh_particles.lua")
	include("sv_transporter_cycle.lua")
	include("sv_transporter_pattern.lua")
	include("sv_transporter.lua")
end

if CLIENT then
	include("sh_sounds.lua")
	include("sh_particles.lua")
	include("cl_transporter.lua")
end
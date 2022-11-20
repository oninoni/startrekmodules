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
--        Transporter | Index        --
---------------------------------------

Star_Trek:RequireModules("util", "sections", "lcars", "sensors")

Star_Trek.Transporter = Star_Trek.Transporter or {}

if SERVER then
	AddCSLuaFile("resources/sh_sounds.lua")
	AddCSLuaFile("resources/sh_particles.lua")
	AddCSLuaFile("sh_loader.lua")

	AddCSLuaFile("sh_transporter_cycle.lua")
	AddCSLuaFile("cl_transporter_cycle.lua")

	AddCSLuaFile("sh_transporter_pads.lua")

	include("sv_config.lua")

	include("resources/sh_sounds.lua")
	include("resources/sh_particles.lua")
	include("sh_loader.lua")

	include("sh_transporter_cycle.lua")
	include("sv_transporter_cycle.lua")

	include("sh_transporter_pads.lua")
	include("sv_transporter_external.lua")

	include("sv_transporter_pattern.lua")
	include("sv_transporter.lua")
end

if CLIENT then
	include("resources/sh_sounds.lua")
	include("resources/sh_particles.lua")
	include("sh_loader.lua")

	include("sh_transporter_cycle.lua")
	include("cl_transporter_cycle.lua")

	include("sh_transporter_pads.lua")
end
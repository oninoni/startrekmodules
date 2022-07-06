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
--           LCARS | Index           --
---------------------------------------

Star_Trek:RequireModules("util")

Star_Trek.LCARS = Star_Trek.LCARS or {}
Star_Trek.LCARS.ActiveInterfaces = Star_Trek.LCARS.ActiveInterfaces or {}

hook.Add("PostCleanupMap", "Star_Trek.LCARS.Cleanup", function()
	Star_Trek.LCARS.ActiveInterfaces = {}
end)

if SERVER then
	AddCSLuaFile("resources/sh_colors.lua")
	AddCSLuaFile("resources/sh_sounds.lua")
	AddCSLuaFile("resources/cl_fonts.lua")

	AddCSLuaFile("sh_loaders.lua")

	AddCSLuaFile("cl_util.lua")
	AddCSLuaFile("cl_lcars_elements.lua")
	AddCSLuaFile("cl_lcars_windows.lua")
	AddCSLuaFile("cl_lcars_interfaces.lua")

	include("resources/sh_colors.lua")
	include("resources/sh_sounds.lua")

	include("sh_loaders.lua")

	include("sv_util.lua")
	include("sv_lcars_windows.lua")
	include("sv_lcars_interfaces.lua")
end

if CLIENT then
	include("resources/sh_colors.lua")
	include("resources/sh_sounds.lua")
	include("resources/cl_fonts.lua")

	include("sh_loaders.lua")

	include("cl_util.lua")
	include("cl_lcars_elements.lua")
	include("cl_lcars_windows.lua")
	include("cl_lcars_interfaces.lua")
end
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
--           LCARS | Index           --
---------------------------------------

Star_Trek:RequireModules("util")

Star_Trek.LCARS = Star_Trek.LCARS or {}

if SERVER then
	AddCSLuaFile("sh_colors.lua")
	AddCSLuaFile("sh_sounds.lua")
	AddCSLuaFile("cl_fonts.lua")
	AddCSLuaFile("cl_util.lua")
	AddCSLuaFile("cl_elements_frame.lua")
	AddCSLuaFile("cl_elements_button.lua")
	AddCSLuaFile("sh_lcars.lua")
	AddCSLuaFile("cl_lcars.lua")

	include("sh_colors.lua")
	include("sh_sounds.lua")
	include("sv_util.lua")
	include("sh_lcars.lua")
	include("sv_lcars.lua")
end

if CLIENT then
	include("sh_colors.lua")
	include("sh_sounds.lua")
	include("cl_fonts.lua")
	include("cl_util.lua")
	include("cl_elements_frame.lua")
	include("cl_elements_button.lua")
	include("sh_lcars.lua")
	include("cl_lcars.lua")
end
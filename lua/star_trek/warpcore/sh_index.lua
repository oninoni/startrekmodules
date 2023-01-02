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
--         Warp Core | Index         --
---------------------------------------

Star_Trek:RequireModules("util")

Star_Trek.WarpCore = Star_Trek.WarpCore or {}

if SERVER then
	AddCSLuaFile("cl_warpcore.lua")

	include("sv_warpcore.lua")
end

if CLIENT then
	include("cl_warpcore.lua")
end
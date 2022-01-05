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
--         Utilities | Index         --
---------------------------------------

Star_Trek:RequireModules()

Star_Trek.Util = Star_Trek.Util or {}

if SERVER then
	AddCSLuaFile("cl_warp.lua")
	--AddCSLuaFile("cl_rendermap.lua")
	
	include("sv_warp.lua")

	include("sv_positions.lua")
	include("sv_keyvalues.lua")
	include("sv_models.lua")

	include("luabsp.lua")
	include("sv_luabsp.lua")
end

if CLIENT then
	include("cl_warp.lua")

	--include("cl_rendermap.lua")
end
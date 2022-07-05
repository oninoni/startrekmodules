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
	AddCSLuaFile("sh_stardate.lua")
	--AddCSLuaFile("sh_benchmark.lua")

	--AddCSLuaFile("cl_rendermap.lua")

	include("sh_stardate.lua")
	--include("sh_benchmark.lua")

	include("sv_airlock.lua")

	include("sv_positions.lua")
	include("sv_keyvalues.lua")

	include("luabsp.lua")
	include("sv_luabsp.lua")
end

if CLIENT then
	include("sh_stardate.lua")
	--include("sh_benchmark.lua")

	--include("cl_rendermap.lua")
end
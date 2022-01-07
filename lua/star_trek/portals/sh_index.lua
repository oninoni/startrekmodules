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
--          Portals | Index          --
---------------------------------------

Star_Trek:RequireModules()

Star_Trek.Portals = Star_Trek.Portals or {}

if SERVER then
	AddCSLuaFile("sh_portals.lua")
	AddCSLuaFile("cl_portals.lua")

	include("sh_portals.lua")
	include("sv_portals.lua")
end

if CLIENT then
	include("sh_portals.lua")
	include("cl_portals.lua")
end
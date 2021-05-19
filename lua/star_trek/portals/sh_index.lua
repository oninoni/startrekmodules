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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--          Portals | Index          --
---------------------------------------

Star_Trek:RequireModules()

-- TODO: Doors Addon removed Compatibility

if SERVER then
	AddCSLuaFile("cl_portals.lua")

	include("sv_portals.lua")
end

if CLIENT then
	include("cl_portals.lua")
end
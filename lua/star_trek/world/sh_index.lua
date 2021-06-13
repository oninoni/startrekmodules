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
--           World | Index           --
---------------------------------------

Star_Trek:RequireModules()

Star_Trek.World = Star_Trek.World or {}

if SERVER then
	AddCSLuaFile("cl_world.lua")
end

if CLIENT then
	include("cl_world.lua")
end
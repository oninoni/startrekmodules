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
--          Sensors | Index          --
---------------------------------------

Star_Trek:RequireModules()

Star_Trek.Sensors = Star_Trek.Sensors or {}

if SERVER then
	AddCSLuaFile("sh_sensors.lua")

	include("sh_sensors.lua")
end

if CLIENT then
	include("sh_sensors.lua")
end
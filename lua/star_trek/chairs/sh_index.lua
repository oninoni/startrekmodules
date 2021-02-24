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
--           Chairs | Index          --
---------------------------------------

Star_Trek.Chairs = Star_Trek.Chairs or {}

if SERVER then
	AddCSLuaFile("sh_config.lua")
	AddCSLuaFile("sh_vehicles.lua")

	include("sh_config.lua")
	include("sh_vehicles.lua")
	include("sv_chairs.lua")
end

if CLIENT then
	include("sh_config.lua")
	include("sh_vehicles.lua")
end
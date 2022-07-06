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
--           Alert | Index           --
---------------------------------------

Star_Trek:RequireModules()

Star_Trek.Alert = Star_Trek.Alert or {}

if SERVER then
	AddCSLuaFile("sh_config.lua")
	AddCSLuaFile("sh_sounds.lua")
	AddCSLuaFile("cl_alert.lua")

	include("sh_config.lua")
	include("sh_sounds.lua")
	include("sv_alert.lua")
end

if CLIENT then
	include("sh_config.lua")
	include("sh_sounds.lua")
	include("cl_alert.lua")
end
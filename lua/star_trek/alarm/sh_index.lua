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
--           Alarm | Index           --
---------------------------------------

Star_Trek:RequireModules()

Star_Trek.Alarm = Star_Trek.Alarm or {}

if SERVER then
	AddCSLuaFile("sh_alarm.lua")
	AddCSLuaFile("cl_alarm.lua")

	include("sh_alarm.lua")
	include("sv_alarm.lua")
end

if CLIENT then
	include("sh_alarm.lua")
	include("cl_alarm.lua")
end
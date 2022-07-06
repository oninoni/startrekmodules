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
--          Security | Index         --
---------------------------------------

Star_Trek:RequireModules("sections", "lcars", "doors", "force_field", "sensors")

Star_Trek.Security = Star_Trek.Security or {}

if SERVER then
	include("sv_sub_consoles.lua")
end

if CLIENT then
	return
end
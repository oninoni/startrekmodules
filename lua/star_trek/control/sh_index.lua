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
--          Control | Index          --
---------------------------------------

Star_Trek:RequireModules("sections")

Star_Trek.Control = Star_Trek.Control or {}

if SERVER then
	include("sv_control.lua")
end

if CLIENT then
	return
end
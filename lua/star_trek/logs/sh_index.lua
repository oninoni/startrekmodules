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
--            Logs | Index           --
---------------------------------------

Star_Trek:RequireModules("lcars")

Star_Trek.Logs = Star_Trek.Logs or {}

if SERVER then
	include("sv_logs.lua")
end

if CLIENT then
	return
end
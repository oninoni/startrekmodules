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
--            Logs | Index           --
---------------------------------------

Star_Trek:RequireModules("lcars", "sections")

Star_Trek.Logs = Star_Trek.Logs or {}

if SERVER then
	include("sv_config.lua")

	include("sv_logs.lua")
	include("sv_logs_archive.lua")
end

if CLIENT then
	return
end
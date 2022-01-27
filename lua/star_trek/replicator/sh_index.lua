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
--         Replicator | Index        --
---------------------------------------

Star_Trek:RequireModules("util", "lcars", "transporter")

Star_Trek.Replicator = Star_Trek.Replicator or {}

if SERVER then
	include("sv_config.lua")
	include("sv_replicator.lua")
end
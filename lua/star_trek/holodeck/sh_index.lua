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
--          Holodeck | Index         --
---------------------------------------

Star_Trek:RequireModules("util", "lcars")

Star_Trek.Holodeck = Star_Trek.Holodeck or {}

if SERVER then
	include("sv_holodeck.lua")
end
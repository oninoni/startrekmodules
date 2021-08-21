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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--         Tricorder | Index         --
---------------------------------------

Star_Trek:RequireModules("lcars_swep")

Star_Trek.Tricorder = Star_Trek.Tricorder or {}

if SERVER then
	include("sv_tricorder.lua")
end
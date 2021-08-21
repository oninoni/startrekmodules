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
--            PADD | Index           --
---------------------------------------

Star_Trek:RequireModules("lcars_swep")

Star_Trek.PADD = Star_Trek.PADD or {}

if SERVER then
	include("sv_padd.lua")
end
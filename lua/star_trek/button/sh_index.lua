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
--           Button | Index          --
---------------------------------------

Star_Trek:RequireModules("lcars")

Star_Trek.Button = Star_Trek.Button or {}

if SERVER then
	include("sv_button.lua")
end

if CLIENT then
	return
end
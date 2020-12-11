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
--          Sections | Index         --
---------------------------------------

Star_Trek.Sections = Star_Trek.Sections or {}

if SERVER then
	include("sv_config.lua")
	include("sv_sections.lua")
end
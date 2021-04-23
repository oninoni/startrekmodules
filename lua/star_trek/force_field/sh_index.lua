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
--        Force Field | Index        --
---------------------------------------

Star_Trek.Force_Field = Star_Trek.Force_Field or {}

if SERVER then
	include("sv_config.lua")
	include("sv_force_field.lua")
end
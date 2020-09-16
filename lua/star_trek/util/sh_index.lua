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
--         Utilities | Index         --
---------------------------------------

Star_Trek.Util = Star_Trek.Util or {}

if SERVER then
    include("sv_positions.lua")
    include("sv_keyvalues.lua")
    include("sv_holodeck.lua")
end
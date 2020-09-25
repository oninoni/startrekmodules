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
    AddCSLuaFile("sh_message.lua")

    include("sh_message.lua")
    include("sv_positions.lua")
    include("sv_keyvalues.lua")
    include("sv_holodeck.lua")
end

if CLIENT then
    include("sh_message.lua")
end
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
--           Damage | Index          --
---------------------------------------

Star_Trek.Damage = Star_Trek.Damage or {}

if CLIENT then
    include("cl_damage.lua")
end

if SERVER then
    AddCSLuaFile("cl_damage.lua")
end
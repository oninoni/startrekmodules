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
--           Doors | Index           --
---------------------------------------

Star_Trek.Doors = Star_Trek.Doors or {}

if SERVER then
    AddCSLuaFile("cl_doors.lua")

    include("sv_config.lua")
    include("sv_doors.lua")
end

if CLIENT then
    include("cl_doors.lua")
end
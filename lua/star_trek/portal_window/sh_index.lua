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
--       Portal Window | Index       --
---------------------------------------

if SERVER then
    AddCSLuaFile("cl_portal_window.lua")

    include("sv_portal_window.lua")
end

if CLIENT then
    include("cl_portal_window.lua")
end
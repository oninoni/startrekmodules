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
--           LCARS | Index           --
---------------------------------------

Star_Trek.LCARS = Star_Trek.LCARS or {}

if SERVER then
    AddCSLuaFile("sh_config.lua")
    AddCSLuaFile("sh_colors.lua")
    AddCSLuaFile("cl_fonts.lua")
    AddCSLuaFile("sh_lcars.lua")
    AddCSLuaFile("cl_lcars.lua")

    include("sh_config.lua")
    include("sh_colors.lua")
    include("sh_lcars.lua")
    include("sv_lcars.lua")
end

if CLIENT then
    include("sh_config.lua")
    include("sh_colors.lua")
    include("cl_fonts.lua")
    include("sh_lcars.lua")
    include("cl_lcars.lua")
end
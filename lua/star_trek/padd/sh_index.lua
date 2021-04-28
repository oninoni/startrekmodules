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
--            PADD | Index           --
---------------------------------------

Star_Trek.PADD = Star_Trek.PADD or {}

if SERVER then
	AddCSLuaFile("sh_padd.lua")
	AddCSLuaFile("cl_padd.lua")

	include("sh_padd.lua")
	include("sv_padd.lua")
end

if CLIENT then
	include("sh_padd.lua")
	include("cl_padd.lua")
end
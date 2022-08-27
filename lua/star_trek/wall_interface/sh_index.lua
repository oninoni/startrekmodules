---------------------------------------
---------------------------------------
--         Star Trek Modules         --
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
--       Wall Interface | Index      --
---------------------------------------

Star_Trek:RequireModules("util", "lcars")

Star_Trek.WallInterface = Star_Trek.WallInterface or {}

if SERVER then
	include("sv_wall_interface.lua")
end

if CLIENT then
	return
end

if game.GetMap() ~= "rp_intrepid_v1" then return end

local removeBridgeInterfaces = function()
	local engineeringWallInterface = ents.FindByName("bridgeBut3")
	for _, ent in pairs(engineeringWallInterface) do
		ent:Remove()
	end

	local scienceWallInterface 	   = ents.FindByName("bridgeBut2")
	for _, ent in pairs(scienceWallInterface) do
		ent:Remove()
	end
end

hook.Add("InitPostEntity", "Star_Trek.WallInterface.RemoveBridge", removeBridgeInterfaces)
hook.Add("PostCleanupMap", "Star_Trek.WallInterface.RemoveBridge", removeBridgeInterfaces)
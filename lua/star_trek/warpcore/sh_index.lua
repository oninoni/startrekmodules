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
--         Warp Core | Index         --
---------------------------------------

Star_Trek:RequireModules("lcars", "util")

Star_Trek.WarpCore = Star_Trek.WarpCore or {}

if SERVER then
	AddCSLuaFile("cl_warpcore.lua")

	include("sv_config.lua")
	include("sv_warpcore.lua")
end

if CLIENT then
	include("cl_warpcore.lua")

	return
end

if game.GetMap() ~= "rp_intrepid_v1" then return end

local setupButton = function()
	if IsValid(Star_Trek.WarpCore.Button) then
		Star_Trek.WarpCore.Button:Remove()
	end

	local core_but1 = ents.FindByName("coreBut1")[1]
	local pos = core_but1:GetPos()
	local ang = core_but1:GetAngles()

	pos = pos - ang:Forward() * 20.25 - ang:Right() * 16.25 - Vector(0, 0, 4)
	ang = ang + Angle(0, -45, 0)

	local success, ent = Star_Trek.Button:CreateButton(pos, ang, "models/hunter/blocks/cube025x025x025.mdl", nil)
	if not success then
		print(ent)
	end

	Star_Trek.WarpCore.Button = ent
end

hook.Add("InitPostEntity", "Star_Trek.WarpCore.SpawnButton", setupButton)
hook.Add("PostCleanupMap", "Star_Trek.WarpCore.SpawnButton", setupButton)
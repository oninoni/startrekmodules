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
--          Tactical | Index         --
---------------------------------------

Star_Trek:RequireModules("lcars", "button")

Star_Trek.Tactical = Star_Trek.Tactical or {}

if SERVER then
	include("sv_tactical.lua")
end

if CLIENT then
	return
end

if game.GetMap() ~= "rp_intrepid_v1" then return end

local setupButton = function()
	if IsValid(Star_Trek.Tactical.Button) then
		Star_Trek.Tactical.Button:Remove()
	end

	local eng_security = ents.FindByName("bridgeBut7")[1]
	local pos = eng_security:GetPos()
	local ang = eng_security:GetAngles()

	pos = pos - ang:Forward() * 68 + ang:Right() * 58 - ang:Up() * 30
	ang = ang + Angle(0, 45, 0)

	local success, ent = Star_Trek.Button:CreateInterfaceButton(pos, ang, "models/hunter/blocks/cube05x2x025.mdl", "tactical")
	if not success then
		print(ent)
	end
	Star_Trek.Tactical.Button = ent
end

hook.Add("InitPostEntity", "Star_Trek.Tactical.SpawnButton", setupButton)
hook.Add("PostCleanupMap", "Star_Trek.Tactical.SpawnButton", setupButton)
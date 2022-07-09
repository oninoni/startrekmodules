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
--          Control | Index          --
---------------------------------------

Star_Trek:RequireModules("sections")

Star_Trek.Control = Star_Trek.Control or {}

if SERVER then
	include("sv_control.lua")
end

if CLIENT then
	return
end

if game.GetMap() ~= "rp_intrepid_v1" then return end

local setupButton = function()
	if IsValid(Star_Trek.Control.Button) then
		Star_Trek.Control.Button:Remove()
	end

	local eng_security = ents.FindByName("gb63")[1]
	local pos = eng_security:GetPos()
	local ang = eng_security:GetAngles()

	pos = pos - ang:Right() * 96 + ang:Forward() * 30
	ang = ang + Angle(0, 56.5, 90)

	local success, ent = Star_Trek.Button:CreateInterfaceButton(pos, ang, "models/hunter/blocks/cube125x125x025.mdl", "diagnostics")
	if not success then
		print(ent)
	end
	Star_Trek.Control.Button = ent
end

hook.Add("InitPostEntity", "Star_Trek.Control.SpawnButton", setupButton)
hook.Add("PostCleanupMap", "Star_Trek.Control.SpawnButton", setupButton)
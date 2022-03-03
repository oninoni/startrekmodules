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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--            Logs | Index           --
---------------------------------------

Star_Trek:RequireModules("lcars", "button", "sections")

Star_Trek.Logs = Star_Trek.Logs or {}

if SERVER then
	include("sv_logs.lua")
	include("sv_logs_archive.lua")
end

if CLIENT then
	return
end

if game.GetMap() ~= "rp_intrepid_v0_9" then return end

local setupButton = function()
	if IsValid(Star_Trek.Logs.Button) then
		Star_Trek.Logs.Button:Remove()
	end

	local eng_security = ents.FindByName("gb60")[1]
	local pos = eng_security:GetPos()
	local ang = eng_security:GetAngles()

	pos = pos + ang:Right() * 96 + ang:Forward() * 30
	ang = ang + Angle(0, 123.5, 90)

	local success, ent = Star_Trek.Button:CreateInterfaceButton(pos, ang, "models/hunter/blocks/cube125x125x025.mdl", "eng_logs")
	if not success then
		print(ent)
	end
	Star_Trek.Logs.Button = ent
end

hook.Add("InitPostEntity", "Star_Trek.Logs.SpawnButton", setupButton)
hook.Add("PostCleanupMap", "Star_Trek.Logs.SpawnButton", setupButton)
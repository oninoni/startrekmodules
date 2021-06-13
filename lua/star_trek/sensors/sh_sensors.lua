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
--          Sensors | Shared         --
---------------------------------------

-- Sensor data Struct
-- Some Values can be Nil

--[[
{
	Name = "Human", -- Name of the Object (Trying to find the best name, REQUIRED)
	Alive = true, -- If the object is alive (REQUIRED)
	Replicated = false,
	Holographic = false,
	Species = "",
}
]]

-- Returns the Scan Data Struct of a given entity.
function Star_Trek.Scanners:ScanEntity(ent)
	if not IsValid(ent) then
		return false, "Invalid Entity"
	end

	local scanData = {
		Name = "Object",
		Alive = false,
	}

	hook.Run("Star_Trek.Scanners.PreScanEntity", ent, scanData)

	-- Check Players.
	if ent:IsPlayer() then
		scanData.Name = ent:GetName()
		scanData.Alive = true

		local overrideName = hook.Run("Star_Trek.Scanners.GetPlayerName", ent)
		if isstring(overrideName) then
			scanData.Name = overrideName
		end

		local overrideAlive = hook.Run("Star_Trek.Scanners.GetPlayerAlive", ent)
		if isbool(overrideAlive) then
			scanData.Alive = overrideAlive
		end
	end

	-- Check NPCs
	if ent:IsNPC() then
		scanData.Name = ent:GetName()
		scanData.Alive = true

		local overrideName = hook.Run("Star_Trek.Scanners.GetNPCName", ent)
		if isstring(overrideName) then
			scanData.Name = overrideName
		end

		local overrideAlive = hook.Run("Star_Trek.Scanners.GetNPCAlive", ent)
		if isbool(overrideAlive) then
			scanData.Alive = overrideAlive
		end
	end

	-- Check Nextbots
	if ent:IsNextBot() then
		scanData.Name = ent:GetName()
		scanData.Alive = true

		local overrideName = hook.Run("Star_Trek.Scanners.GetNextbotName", ent)
		if isstring(overrideName) then
			scanData.Name = overrideName
		end

		local overrideAlive = hook.Run("Star_Trek.Scanners.GetNextbotAlive", ent)
		if isbool(overrideAlive) then
			scanData.Alive = overrideAlive
		end
	end

	hook.Run("Star_Trek.Scanners.PostScanEntity", ent, scanData)

	return true, scanData
end
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
--          Sensors | Server         --
---------------------------------------

-- Returns the Scan Data Struct of a given entity.
function Star_Trek.Sensors:ScanEntity(ent)
	if not IsValid(ent) then
		return false, "Invalid Entity"
	end

	local scanData = {
		Name = "Unknown Object",
		Alive = false,
	}

	hook.Run("Star_Trek.Sensors.PreScanEntity", ent, scanData)

	-- Check Players.
	if ent:IsPlayer() then
		local name = ent:GetName()
		if not isstring(name) or name == "" then
			name = "Unknown Lifeform"
		end

		scanData.Name = name
		scanData.Alive = true

		hook.Run("Star_Trek.Sensors.ScanPlayer", ent, scanData)
	end

	-- Check NPCs
	if ent:IsNPC() then
		local name = ent:GetName()
		if not isstring(name) or name == "" then
			name = "Unknown Lifeform"
		end

		scanData.Name = name
		scanData.Alive = true

		hook.Run("Star_Trek.Sensors.ScanNPC", ent, scanData)
	end

	-- Check Nextbots
	if ent:IsNextBot() then
		local name = ent:GetName()
		if not isstring(name) or name == "" then
			name = "Unknown Lifeform"
		end

		scanData.Name = name
		scanData.Alive = true

		hook.Run("Star_Trek.Sensors.ScanNextBot", ent, scanData)
	end

	-- Check Weapons
	if ent:IsWeapon() then
		local weaponTable = weapons.GetStored(ent:GetClass())
		if istable(weaponTable) then
			name = weaponTable.PrintName
		else
			name = "Unknown Handheld Object"
		end

		scanData.Name = name
		scanData.Alive = false

		hook.Run("Star_Trek.Sensors.ScanWeapon", ent, scanData)
	end

	hook.Run("Star_Trek.Sensors.PostScanEntity", ent, scanData)

	return true, scanData
end

-- Scan Health
hook.Add("Star_Trek.Sensors.PostScanEntity", "Sensors.CheckHealth", function(ent, scanData)
	local maxHealth = ent:GetMaxHealth()
	if maxHealth == 0 then
		return
	end

	local percentage = ent:Health() / maxHealth
	scanData.Integrity = math.Round(percentage * 100, 0)
end)
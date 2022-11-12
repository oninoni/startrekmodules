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
--          Sensors | Server         --
---------------------------------------

-- Returns the Scan Data Struct of a given entity.
function Star_Trek.Sensors:ScanEntity(ent)
	if not IsValid(ent) then
		return false, "Invalid Entity"
	end

	local scanData = {}

	hook.Run("Star_Trek.Sensors.PreScanEntity", ent, scanData)

	-- Check for Entities with non-zero health
	local maxHealth = ent:GetMaxHealth()
	local health = ent:Health()
	if maxHealth > 1 or health > 0 then
		local percentage = (health or 0) / (maxHealth or 1)
		scanData.Health = math.Round(percentage * 100, 0)
	end

	-- Check Players.
	if ent:IsPlayer() then
		scanData.Name = ent:GetName()

		scanData.Alive = true
		hook.Run("Star_Trek.Sensors.ScanPlayer", ent, scanData)
	end

	-- Check NPCs
	if ent:IsNPC() then
		local npcTables = list.Get("NPC")
		if istable(npcTables) then
			local npcTable = npcTables[ent:GetClass()]
			if istable(npcTable) then
				local name = npcTable.Name
				if isstring(name) and name ~= "" then
					scanData.Name = name
				end
			end
		end

		scanData.Alive = true
		hook.Run("Star_Trek.Sensors.ScanNPC", ent, scanData)
	end

	-- Check Nextbots
	if ent:IsNextBot() then
		local npcTables = list.Get("NPC")
		if istable(npcTables) then
			local npcTable = npcTables[ent:GetClass()]
			if istable(npcTable) then
				local name = npcTable.Name
				if isstring(name) and name ~= "" then
					scanData.Name = name
				end
			end
		end

		scanData.Alive = true
		hook.Run("Star_Trek.Sensors.ScanNextBot", ent, scanData)
	end

	-- Check Weapons
	if ent:IsWeapon() then
		local weaponTables = list.Get("Weapon")
		if istable(weaponTables) then
			local weaponTable = weaponTables[ent:GetClass()]
			if istable(weaponTable) then
				local name = weaponTable.PrintName
				if isstring(name) and name ~= "" then
					scanData.Name = name
				end
			end
		end

		scanData.IsWeapon = true
		hook.Run("Star_Trek.Sensors.ScanWeapon", ent, scanData)
	end

	if ent:IsVehicle() then
		local vehicleTables = list.Get("Vehicles")
		if istable(vehicleTables) then
			local vehicleTable = vehicleTables[ent:GetClass()]
			if istable(vehicleTable) then
				local name = vehicleTable.PrintName
				if isstring(name) and name ~= "" then
					scanData.Name = name
				end
			end
		end

		scanData.IsVehicle = true
		hook.Run("Star_Trek.Sensors.ScanVehicle", ent, scanData)
	end

	-- Check entity name.
	local entityTables = list.Get("SpawnableEntities")
	if istable(entityTables) then
		local entityTable = entityTables[ent:GetClass()]
		if istable(entityTable) then
			local name = entityTable.PrintName
			if isstring(name) and name ~= "" then
				scanData.Name = name
			end
		end
	end

	-- Check for Scripted Entities
	if ent:IsScripted() and not ent:IsWeapon() then
		local name = ent.PrintName
		if isstring(name) and name ~= "" then
			scanData.Name = name
		end

		hook.Run("Star_Trek.Sensors.ScanScriptedEntity", ent, scanData)
	end

	-- Check for named entities.
	if ent:MapCreationID() == -1 then
		local name = ent:GetName()
		if isstring(name) and name ~= "" then
			scanData.Name = name
		end
	end

	hook.Run("Star_Trek.Sensors.ScanEntity", ent, scanData)

	if isstring(ent.OverrideName) and ent.OverrideName ~= "" then
		scanData.Name = ent.OverrideName
	end

	-- Set name placeholders when no name is registered
	if not isstring(scanData.Name) then
		if scanData.Alive then
			scanData.Name = "Unidentified Lifeform"
		elseif scanData.IsWeapon then
			scanData.Name = "Unidentified Handheld Object"
		else
			scanData.Name = "Unidentified Object"
		end
	end

	hook.Run("Star_Trek.Sensors.PostScanEntity", ent, scanData)

	return true, scanData
end

-- Check for Players with non-zero armor.
hook.Add("Star_Trek.Sensors.ScanPlayer", "Sensors.CheckArmor", function(ent, scanData)
	local maxArmor = ent:GetMaxArmor()
	local armor = ent:Armor()
	if maxArmor > 0 or armor > 0 then
		local percentage = (armor or 0) / (maxArmor or 1)
		scanData.Armor = math.Round(percentage * 100, 0)
	end
end)

hook.Add("Star_Trek.Sensors.ScanPlayer", "Sensors.CheckWeapons", function(ent, scanData)
	scanData.Weapons = {}

	local weaponBlacklist = {}
	hook.Run("Star_Trek.Sensors.BlacklistWeapons", weaponBlacklist)

	for _, weapon in pairs(ent:GetWeapons()) do
		if table.HasValue(weaponBlacklist, weapon:GetClass()) then continue end

		local success, wepScanData = Star_Trek.Sensors:ScanEntity(weapon)
		if not success then
			continue
		end

		table.insert(scanData.Weapons, wepScanData)
	end
end)

-- Record Entity Physics Object.
hook.Add("Star_Trek.Sensors.ScanEntity", "Sensors.CheckMass", function(ent, scanData)
	local physCount = ent:GetPhysicsObjectCount()
	if physCount == 1 then
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			scanData.Mass = phys:GetMass()

			if not phys:IsMotionEnabled() then
				scanData.Frozen = true
			end
		end
	else
		scanData.Mass = 0
		for i = 0, physCount - 1 do
			local phys = ent:GetPhysicsObjectNum(i)
			if IsValid(phys) then
				scanData.Mass = scanData.Mass + phys:GetMass()
			end
		end
	end
end)

hook.Add("Star_Trek.Sensors.ScanScriptedEntity", "Sensors.CheckVFire", function(ent, scanData)
	local className = ent:GetClass()
	if string.StartWith(className, "vfire") then
		scanData.IsFire = true
	end
end)
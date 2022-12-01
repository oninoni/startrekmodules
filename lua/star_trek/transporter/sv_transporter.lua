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
--        Transporter | Server       --
---------------------------------------

-- Set up buffer and beam locations.
hook.Add("Star_Trek.Sections.Loaded", "Star_Trek.Transporter.DetectLocations", function()
	Star_Trek.Transporter.Buffer = {
		Entities = {},
		Pos = Vector(),
	}

	local bufferEntities = ents.FindByName("beamBuffer")
	if istable(bufferEntities) and IsValid(bufferEntities[1]) then
		Star_Trek.Transporter.Buffer.Pos = bufferEntities[1]:GetPos()
	end

	for deck, deckData in pairs(Star_Trek.Sections.Decks) do
		for sectionId, sectionData in pairs(deckData.Sections) do
			sectionData.BeamLocations = {}

			local objects = Star_Trek.Sections:GetInSection(deck, sectionId, function(object)
				local ent = object.Entity
				if ent:GetName() ~= "beamLocation" then
					return true
				end
			end, true)

			for _, object in pairs(objects) do
				local ent = object.Entity
				table.insert(sectionData.BeamLocations, ent:GetPos())

				ent:Remove()
			end
		end
	end
end)

function Star_Trek.Transporter:CanBeamTo(ent, pos)
	local min, max = ent:GetRotatedAABB(ent:OBBMins(), ent:OBBMaxs())
	max.z = max.z - min.z
	min.z = 0

	local offsetPos = pos + Vector(0, 0, 2)

	local trace = util.TraceHull({
		start = offsetPos,
		endpos = offsetPos,
		maxs = max,
		mins = min,
		filter = {
			ent
		}
	})

	if trace.Hit then
		return false
	end

	for _, transporterCycle in pairs(self.ActiveCycles) do
		if transporterCycle.TargetPos:Distance(pos) < 16 then
			return false
		end
	end

	return true
end

function Star_Trek.Transporter:RemoveWeapons(interfaceEnt, ply, scanData)
	local weaponsFound = false

	for _, weapon in pairs(ply:GetWeapons()) do

		local success, weaponScanData = Star_Trek.Sensors:ScanEntity(weapon)
		if success then
			if weaponScanData.HarmlessWeapon then continue end

			Star_Trek.Logs:AddEntry(interfaceEnt, ply, "WARNING: Weapon detected on " .. scanData.Name .. ": " .. weaponScanData.Name .. ", Sending weapon to buffer...", Star_Trek.LCARS.ColorRed)

			ply:DropWeapon(weapon, ply:GetPos(), Vector(0, 0, 0))
			local phys = weapon:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end

			table.insert(Star_Trek.Transporter.Buffer.Entities, weapon)
			weapon.BufferQuality = 160

			weaponsFound = true
		end
	end

	if weaponsFound then
		interfaceEnt:EmitSound("star_trek.lcars_alert14")
	end
end

function Star_Trek.Transporter:ActivateTransporter(interfaceEnt, ply, sourcePatterns, targetPatterns, cycleClass, noBuffer, allowWeapons)
	if not istable(sourcePatterns) then return end

	Star_Trek.Logs:AddEntry(interfaceEnt, ply, "")
	Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Initialising Transporter...")
	Star_Trek.Logs:AddEntry(interfaceEnt, ply, table.Count(sourcePatterns) .. " Pattern Sources Detected.")
	Star_Trek.Logs:AddEntry(interfaceEnt, ply, table.Count(sourcePatterns) .. " Pattern Targets Detected.")

	local updateBuffer = false
	for _, sourcePattern in pairs(sourcePatterns) do
		local ent = sourcePattern.Ent

		if IsEntity(ent) and not IsValid(ent) then
			continue
		end

		local isBuffer = table.HasValue(Star_Trek.Transporter.Buffer.Entities, ent)

		local successfulTransport = false
		for _, targetPattern in pairs(targetPatterns) do
			if targetPattern.Used then
				continue
			end

			local pos = targetPattern.Pos
			if not targetPattern.AllowBeam and not sourcePattern.AllowBeam and not self:CanBeamTo(ent, pos) then
				continue
			end

			if isBuffer then
				table.RemoveByValue(Star_Trek.Transporter.Buffer.Entities, ent)

				updateBuffer = true
			end

			local success, scanData = Star_Trek.Sensors:ScanEntity(ent)
			if success then
				Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Dematerialising " .. scanData.Name .. "...")
			end

			Star_Trek.Transporter:TransportObject(cycleClass or "base", ent, pos, isBuffer, false, function(transporterCycle)
				Star_Trek.Transporter:ApplyPadEffect(transporterCycle, sourcePattern.Pad, targetPattern.Pad)

				local state = transporterCycle.State
				if state == 2 and success then
					Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Rematerialising " .. scanData.Name .. "...")

					if not allowWeapons and ent:IsPlayer() then
						Star_Trek.Transporter:RemoveWeapons(interfaceEnt, ent, scanData)
					end
				end
			end)

			targetPattern.Used = true
			successfulTransport = true

			break
		end

		if successfulTransport then
			continue
		end

		if noBuffer then
			Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Buffer Usage Prevented!", Star_Trek.LCARS.ColorOrange)
			continue
		end

		if isBuffer then
			Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Buffer Recursion Prevented!", Star_Trek.LCARS.ColorOrange)
			continue
		end

		-- Beam into Buffer
		table.insert(Star_Trek.Transporter.Buffer.Entities, ent)
		ent.BufferQuality = 160

		if istable(ent) then
			Star_Trek.Logs:AddEntry(interfaceEnt, ply, "WARNING: Remote Transporter Request has no target. Aborting!", Star_Trek.LCARS.ColorRed)
			continue
		end
		local success, scanData = Star_Trek.Sensors:ScanEntity(ent)
		if success then
			Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Dematerialising " .. scanData.Name .. "...")
		end
		Star_Trek.Transporter:TransportObject(cycleClass or "base", ent, Vector(), false, true, function(transporterCycle)
			Star_Trek.Transporter:ApplyPadEffect(transporterCycle, sourcePattern.Pad)
		end)

		Star_Trek.Logs:AddEntry(interfaceEnt, ply, "WARNING: No Free Target Position Available! Storing in Buffer!", Star_Trek.LCARS.ColorRed)

		if success and scanData.Alive then
			Star_Trek.Logs:AddEntry(interfaceEnt, ply, "WARNING: " .. scanData.Name .. " has been transported to the Buffer!", Star_Trek.LCARS.ColorRed)
			local timerName = "Star_Trek.Transporter.BufferAlert." .. interfaceEnt:EntIndex()

			if timer.Exists(timerName) then
				continue
			end

			-- 5x Alert Sound
			timer.Create(timerName, 1, 5, function()
				interfaceEnt:EmitSound("star_trek.lcars_alert14")
			end)
		end
	end

	if updateBuffer then
		hook.Run("Star_Trek.Transporter.UpdateBuffer", ent, interfaceEnt)
	end
end
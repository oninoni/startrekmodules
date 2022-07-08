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

			local beamLocationEntities = Star_Trek.Sections:GetInSection(deck, sectionId, function(objects, ent)
				if ent:GetName() ~= "beamLocation" then
					return true
				end
			end, true)

			for _, ent in pairs(beamLocationEntities) do
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

function Star_Trek.Transporter:ActivateTransporter(interfaceEnt, ply, sourcePatterns, targetPatterns, cycleClass, noBuffer)
	if not istable(sourcePatterns) then return end

	Star_Trek.Logs:AddEntry(interfaceEnt, ply, "")
	Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Initialising Transporter...")
	Star_Trek.Logs:AddEntry(interfaceEnt, ply, table.Count(sourcePatterns) .. " Pattern Sources Detected.")
	Star_Trek.Logs:AddEntry(interfaceEnt, ply, table.Count(sourcePatterns) .. " Pattern Targets Detected.")	

	for _, sourcePattern in pairs(sourcePatterns) do
		local ent = sourcePattern.Ent

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
			end
			
			local success, scanData = Star_Trek.Sensors:ScanEntity(ent)
			if success then
				Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Dematerialising " .. scanData.Name .. "...")
			end
			
			Star_Trek.Transporter:TransportObject(cycleClass or "base", ent, pos, isBuffer, false, function(transporterCycle)
				Star_Trek.Transporter:ApplyPadEffect(transporterCycle, sourcePattern.Pad, targetPattern.Pad)

				local state = transporterCycle.State
				if state == 2 then
					if success then
						Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Rematerialising ".. scanData.Name .. "...")
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
			Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Buffer Usage Prevented!")
			continue
		end

		if isBuffer then
			Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Buffer Recursion Prevented!")
			continue
		end

		-- Beam into Buffer
		table.insert(Star_Trek.Transporter.Buffer.Entities, ent)
		ent.BufferQuality = 160
		if istable(ent) then
			Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Warning: Remote Transporter Request has no target. Aborting!")
			continue
		end
		local success, scanData = Star_Trek.Sensors:ScanEntity(ent)
		if success then
			Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Dematerialising " .. scanData.Name .. "...")
		end
		Star_Trek.Transporter:TransportObject(cycleClass or "base", ent, Vector(), false, true, function(transporterCycle)
			Star_Trek.Transporter:ApplyPadEffect(transporterCycle, sourcePattern.Pad)
		end)

		Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Warning: No Free Target Position Available! Storing in Buffer!")
		
		if success then
			if scanData.Alive then
				Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Warning: ".. scanData.Name .. " has been transported to the Buffer!")
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
	end
end
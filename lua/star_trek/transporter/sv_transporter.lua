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

function Star_Trek.Transporter:CleanUpSourcePatterns(patterns)
	if not istable(patterns) then return {} end
	local invalidPatterns = {}

	for name, pattern in pairs(patterns) do
		if istable(pattern) and table.Count(pattern.Entities) == 0 then
			table.insert(invalidPatterns, pattern)
		end
	end

	for _, pattern in pairs(invalidPatterns) do
		table.RemoveByValue(patterns, pattern)
	end

	return patterns
end

function Star_Trek.Transporter:CleanUpTargetPatterns(patterns)
	if not istable(patterns) then return {} end
	local invalidPatterns = {}

	for _, pattern in pairs(patterns) do
		if istable(pattern) and table.Count(pattern.Entities) > 0 then
			table.insert(invalidPatterns, pattern)
		end
	end

	for _, pattern in pairs(invalidPatterns) do
		table.RemoveByValue(patterns, pattern)
	end

	return patterns
end

function Star_Trek.Transporter:ActivateTransporter(interfaceEnt, ply, sourcePatterns, targetPatterns, cycleClass, noBuffer)
	if not istable(sourcePatterns) then return end

	sourcePatterns = self:CleanUpSourcePatterns(sourcePatterns)
	targetPatterns = self:CleanUpTargetPatterns(targetPatterns)

	Star_Trek.Logs:AddEntry(interfaceEnt, ply, "")
	Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Initialising Transporter...")
	Star_Trek.Logs:AddEntry(interfaceEnt, ply, table.Count(sourcePatterns) .. " Pattern Sources Selected.")
	Star_Trek.Logs:AddEntry(interfaceEnt, ply, table.Count(sourcePatterns) .. " Pattern Targets Selected.")
	Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Dematerialising...")

	local targetPatternId = 1
	for _, sourcePattern in pairs(sourcePatterns) do
		if not istable(sourcePattern) then
			continue
		end

		for _, ent in pairs(sourcePattern.Entities) do
			local targetPattern = targetPatterns[targetPatternId]
			if istable(targetPattern) then
				if sourcePatterns.IsBuffer then
					table.RemoveByValue(Star_Trek.Transporter.Buffer.Entities, ent)
				end

				Star_Trek.Transporter:TransportObject(cycleClass or "base", ent, targetPattern.Pos, sourcePatterns.IsBuffer, false, function(transporterCycle)
					Star_Trek.Transporter:ApplyPadEffect(transporterCycle, sourcePattern, targetPattern)

					local state = transporterCycle.State
					if state == 2 then
						Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Rematerialising Object...")
					end
				end)

				Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Dematerialising Object...")

				targetPatternId = targetPatternId + 1
			elseif isbool(targetPattern) then
				continue
			else
				if noBuffer then
					continue
				end

				if sourcePatterns.IsBuffer or table.HasValue(Star_Trek.Transporter.Buffer.Entities, ent) then
					Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Buffer Recursion Prevented!")

					continue
				end

				table.insert(Star_Trek.Transporter.Buffer.Entities, ent)
				ent.BufferQuality = 160

				Star_Trek.Transporter:TransportObject(cycleClass or "base", ent, Vector(), false, true, function(transporterCycle)
					Star_Trek.Transporter:ApplyPadEffect(transporterCycle, sourcePattern, {})
				end)

				Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Dematerialising Object...")
				Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Warning: No Target Pattern Available! Storing in Buffer!")
				if ent:IsPlayer() or ent:IsNPC() then
					Star_Trek.Logs:AddEntry(interfaceEnt, ply, "Warning: Organic Pattern in Buffer detected!")

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
end
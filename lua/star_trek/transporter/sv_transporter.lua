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
		if istable(pattern) then
			if table.Count(pattern.Entities) == 0 then
				table.insert(invalidPatterns, pattern)
			end
		else
			table.RemoveByValue(patterns, pattern)
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
		if istable(pattern) then
			if table.Count(pattern.Entities) > 0 then
				table.insert(invalidPatterns, pattern)
			end
		else
			table.RemoveByValue(patterns, pattern)
		end
	end

	for _, pattern in pairs(invalidPatterns) do
		table.RemoveByValue(patterns, pattern)
	end

	return patterns
end

function Star_Trek.Transporter:ActivateTransporter(sourcePatterns, targetPatterns, textWindow)
	if not istable(sourcePatterns) then return end

	sourcePatterns = self:CleanUpSourcePatterns(sourcePatterns)
	targetPatterns = self:CleanUpTargetPatterns(targetPatterns)

	textWindow:AddLine("Initialising Transporter...")
	textWindow:AddLine(table.Count(sourcePatterns) .. " Pattern Sources Selected.")
	textWindow:AddLine(table.Count(sourcePatterns) .. " Pattern Targets Selected.")
	textWindow:AddLine("Dematerialising...")

	local targetPatternId = 1
	for _, sourcePattern in pairs(sourcePatterns) do
		for _, ent in pairs(sourcePattern.Entities) do
			local targetPattern = targetPatterns[targetPatternId]
			if istable(targetPattern) then
				if sourcePatterns.IsBuffer then
					table.RemoveByValue(Star_Trek.Transporter.Buffer.Entities, ent)
				end

				-- TODO: PAD!
				Star_Trek.Transporter:TransportObject("federation", ent, targetPattern.Pos, false, false, function(...)
					print(...)
				end)

				--self:BeamObject(ent, targetPattern.Pos, sourcePattern.Pad, targetPattern.Pad, false)
				textWindow:AddLine("Dematerialising Object...")

				targetPatternId = targetPatternId + 1
			elseif isbool(targetPattern) then
				continue
			else
				table.insert(Star_Trek.Transporter.Buffer.Entities, ent)
				ent.BufferQuality = 160

				--self:BeamObject(ent, Star_Trek.Transporter.Buffer.Pos, ent.Pad, nil, true)
				textWindow:AddLine("Dematerialising Object...")
				textWindow:AddLine("Warning: No Target Pattern Available! Storing in Buffer!", Star_Trek.LCARS.ColorRed)
			end
		end
	end

	textWindow:AddLine("")
	textWindow:Update()
end
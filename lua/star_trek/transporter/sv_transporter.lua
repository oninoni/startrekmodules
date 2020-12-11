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
--        Transporter | Server       --
---------------------------------------

-- TODO: Check if transport in Progress at target location (No 2 Beams at the same pos at the same time.)
-- TODO: Buffer Decay

local setupBuffer = function()
	for _, ent in pairs(ents.GetAll()) do
		if string.StartWith(ent:GetName(), "beamBuffer") then
			Star_Trek.Transporter.Buffer = {
				Entities = {},
				Pos = ent:GetPos(),
			}

			return
		end
	end
end
hook.Add("InitPostEntity", "Star_Trek.Transporter.Setup", setupBuffer)
hook.Add("PostCleanupMap", "Star_Trek.Transporter.Setup", setupBuffer)

hook.Add("Star_Trek.Sections.Loaded", "Star_Trek.Transporter.DetectLocations", function()
	for deck, deckData in pairs(Star_Trek.Sections.Decks) do
		for sectionId, sectionData in pairs(deckData.Sections) do
			sectionData.BeamLocations = {}

			local entities = Star_Trek.Sections:GetInSection(deck, sectionId, true)

			for _, ent in pairs(entities) do
				if ent:GetName() == "beamLocation" then
					table.insert(sectionData.BeamLocations, ent:GetPos())

					ent:Remove()
				end
			end
		end
	end
end)

hook.Add("SetupPlayerVisibility", "Star_Trek.Transporter.PVS", function(ply, viewEntity)
	if istable(Star_Trek.Transporter.Buffer) then
		AddOriginToPVS(Star_Trek.Transporter.Buffer.Pos)
	end
end)

function Star_Trek.Transporter:CleanUpSourcePatterns(patterns)
	if not istable(patterns) then return patterns end
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
	if not istable(patterns) then return patterns end
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

function Star_Trek.Transporter:ActivateTransporter(sourcePatterns, targetPatterns)
	sourcePatterns = self:CleanUpSourcePatterns(sourcePatterns)
	targetPatterns = self:CleanUpTargetPatterns(targetPatterns)

	local remainingEntities = {}
	if not istable(targetPatterns) then
		for _, sourcePattern in pairs(sourcePatterns) do
			if istable(sourcePattern) then
				for _, ent in pairs(sourcePattern.Entities) do
					table.insert(remainingEntities, ent)
				end
			end
		end
	else
		local i = 1
		for _, sourcePattern in pairs(sourcePatterns) do
			if istable(sourcePattern) then
				for _, ent in pairs(sourcePattern.Entities) do
					local targetPattern = targetPatterns[i]
					if istable(targetPattern) then
						if sourcePatterns.IsBuffer then
							table.RemoveByValue(Star_Trek.Transporter.Buffer.Entities, ent)
						end

						self:BeamObject(ent, targetPattern.Pos, sourcePattern.Pad, targetPattern.Pad, false)

						i = i + 1
					elseif isbool(targetPattern) then
						continue
					else
						if not sourcePatterns.IsBuffer then
							table.insert(remainingEntities, ent)
							ent.Pad = sourcePattern.Pad
						end
					end
				end
			end
		end
	end

	if not sourcePatterns.IsBuffer then
		for _, ent in pairs(remainingEntities) do
			table.insert(Star_Trek.Transporter.Buffer.Entities, ent)
			self:BeamObject(ent, Vector(), ent.Pad, nil, true)
		end
	end
end

hook.Add("PlayerCanPickupItem", "Star_Trek.Transporter.PreventPickup", function(ply, ent)
	for _, transportData in pairs(Star_Trek.Transporter.ActiveTransports) do
		if transportData.Object == ent then return false end
	end

	if ent.Replicated and not (ply:KeyDown(IN_USE) and ply:GetEyeTrace().Entity == ent) then
		return false
	end
end)

hook.Add("PlayerCanPickupWeapon", "Star_Trek.Transporter.PreventPickup", function(ply, ent)
	for _, transportData in pairs(Star_Trek.Transporter.ActiveTransports) do
		if transportData.Object == ent then return false end
	end

	if ent.Replicated and not (ply:KeyDown(IN_USE) and ply:GetEyeTrace().Entity == ent) then
		return false
	end
end)
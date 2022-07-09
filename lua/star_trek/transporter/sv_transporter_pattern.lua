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
--   Transporter Patterns | Server   --
---------------------------------------

function Star_Trek.Transporter:CanBeamEntity(ent)
	if table.HasValue(Star_Trek.Transporter.Buffer.Entities, ent) then
		return true
	end

	if not IsValid(ent) then
		return false
	end

	if ent:MapCreationID() ~= -1 then
		return false
	end

	if IsValid(ent:GetParent()) then
		return false
	end

	local phys = ent:GetPhysicsObject()
	if not IsValid(phys) then
		return false
	end

	if not phys:IsMotionEnabled() then
		return false
	end

	if ent:IsPlayer() and not ent:Alive() then
		return false
	end

	if hook.Run("Star_Trek.Transporter.OverrideCanBeam", ent) == false then
		return false
	end

	return true
end

-- Returns a pattern for the given entity.
--
-- @param Entity ent
-- @param Boolean isTarget
-- @param Boolean wideField
-- @return Table pattern
function Star_Trek.Transporter:GetPatternFromEntity(ent, isTarget, wideField)
	local pattern = {}

	local pos = ent:GetPos()

	if not isTarget then -- Source
		if wideField then
			local range = 64

			local  lowerBounds = pos - Vector(range, range, 0)
			local higherBounds = pos + Vector(range, range, range * 2)
			for _, foundEnt in pairs(ents.FindInBox(lowerBounds, higherBounds)) do
				if Star_Trek.Transporter:CanBeamEntity(foundEnt) then
					table.insert(pattern, {Ent = foundEnt})
				end
			end
		else
			if Star_Trek.Transporter:CanBeamEntity(ent) then
				table.insert(pattern, {Ent = ent})
			end
		end
	else -- Target
		for i = 1, 6 do
			local a = math.rad( ( i / 6 ) * -360 )
			local p = pos + 32 * Vector(math.sin(a), math.cos(a), 0)
			table.insert(pattern, {Pos = p})
		end
	end

	return pattern
end

-- Returns a pattern for the given vector.
--
-- @param Vector pos
-- @param Boolean isTarget
-- @param Boolean wideField
-- @return Table pattern
function Star_Trek.Transporter:GetPatternFromVector(pos, isTarget, wideField)
	local pattern = {}

	if not isTarget then -- Source
		local range = 32
		if wideField then
			range = 64
		end

		local  lowerBounds = pos - Vector(range, range, 0)
		local higherBounds = pos + Vector(range, range, range * 2)
		for _, ent in pairs(ents.FindInBox(lowerBounds, higherBounds)) do
			if Star_Trek.Transporter:CanBeamEntity(ent) then
				table.insert(pattern, {Ent = ent})
			end
		end
	else -- Target
		table.insert(pattern, {Pos = pos})

		for i = 1, 6 do
			local a = math.rad( ( i / 6 ) * -360 )
			local p = pos + 32 * Vector(math.sin(a), math.cos(a), 0)
			table.insert(pattern, {Pos = p})
		end
	end

	return pattern
end

-- Returns a pattern for the given Sections
--
-- @param Entity pad
-- @param Boolean isTarget
-- @return Table pattern
function Star_Trek.Transporter:GetPatternFromPad(pad, isTarget)
	local pattern = {}

	local pos = Star_Trek.Transporter:GetPadPosition(pad)

	if not isTarget then -- Source
		local  lowerBounds = pos - Vector(25, 25, 0)
		local higherBounds = pos + Vector(25, 25, 120)
		for _, foundEnt in pairs(ents.FindInBox(lowerBounds, higherBounds)) do
			if Star_Trek.Transporter:CanBeamEntity(foundEnt) then
				table.insert(pattern, {Pad = pad, Ent = foundEnt})
			end
		end
	else -- Target
		table.insert(pattern, {Pad = pad, Pos = pos})
	end

	return pattern
end

-- Returns a pattern for the given Sections
--
-- @param Number deck
-- @param Table sectionIds
-- @param Boolean isTarget
-- @return Table pattern
function Star_Trek.Transporter:GetPatternFromSections(deck, sectionIds, isTarget)
	local pattern = {}

	if not isTarget then -- Source
		for _, sectionId in pairs(sectionIds) do
			local objects = Star_Trek.Sections:GetInSection(deck, sectionId, function(object)
				local ent = object.Entity
				if not Star_Trek.Transporter:CanBeamEntity(ent) then
					return true
				end
			end)
			for i, object in pairs(objects) do
				table.insert(pattern, {Ent = object.Entity})
			end
		end
	else -- Target
		for _, sectionId in pairs(sectionIds) do
			local success, sectionData = Star_Trek.Sections:GetSection(deck, sectionId)
			if not success then
				continue
			end

			for _, pos in pairs(sectionData.BeamLocations or {}) do
				table.insert(pattern, {Pos = pos})
			end
		end
	end

	return pattern
end

-- Returns a pattern for the given table, which either contains Sections or a Pad Entity.
--
-- @param Table data
-- @param Boolean isTarget
-- @param Boolean wideField
-- @return Table pattern
function Star_Trek.Transporter:GetPatternFromTable(data, isTarget, wideField)
	local deck = data.Deck
	local sectionIds = data.SectionIds

	if isnumber(deck) and istable(sectionIds) then
		return self:GetPatternFromSections(deck, sectionIds, isTarget)
	end

	local pad = data.Pad
	if IsEntity(pad) then
		return self:GetPatternFromPad(pad, isTarget)
	end

	if isfunction(pad) then
		return pad(isTarget, wideField)
	end
end

-- Returns all patterns from the requested patternObjects.
--
-- @param Table patternObjects
-- @param Boolean isTarget
-- @param Boolean wideField
-- @return Table patterns
function Star_Trek.Transporter:GetPatterns(patternObjects, isTarget, wideField)
	local patterns = {}

	for _, patternObject in pairs(patternObjects) do
		local pattern

		if IsEntity(patternObject) then
			pattern = self:GetPatternFromEntity(patternObject, isTarget, wideField)
		elseif isvector(patternObject) then
			pattern = self:GetPatternFromVector(patternObject, isTarget, wideField)
		elseif istable(patternObject) then
			pattern = self:GetPatternFromTable(patternObject, isTarget, wideField)
		elseif isfunction(patternObject) then
			pattern = patternObject(isTarget, wideField)
		end

		if not istable(pattern) then
			continue
		end

		table.insert(patterns, pattern)
	end

	-- Unwrap the patterns into a single table and check for doubles / child entities.
	local unWrappedPatterns = {}
	local patternEntities = {}
	for _, pattern in pairs(patterns) do
		for _, singlePattern in pairs(pattern) do
			local ent = singlePattern.Ent
			if IsEntity(ent) and IsValid(ent) then
				local parent = ent:GetParent()
				if IsValid(parent) then
					continue
				end

				if table.HasValue(patternEntities, ent) then
					continue
				else
					table.insert(patternEntities, ent)
				end
			end

			table.insert(unWrappedPatterns, singlePattern)
		end
	end

	return unWrappedPatterns
end
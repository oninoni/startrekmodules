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
--         Sections | Server         --
---------------------------------------

function Star_Trek.Sections:GetSection(deck, sectionId)
	local deckData = self.Decks[deck]
	if istable(deckData) then
		local sectionData = deckData.Sections[sectionId]
		if istable(sectionData) then
			return sectionData
		end

		return false, "Invalid Section Id!"
	end

	return false, "Invalid Deck!"
end

function Star_Trek.Sections:IsInArea(areaData, entPos)
	local pos = areaData.Pos

	local min = areaData.Min
	local max = areaData.Max

	local localPos = -WorldToLocal(pos, Angle(), entPos, Angle())

	if  localPos[1] > min[1] and localPos[1] < max[1]
	and localPos[2] > min[2] and localPos[2] < max[2]
	and localPos[3] > min[3] and localPos[3] < max[3] then
		return true
	end

	return false
end

function Star_Trek.Sections:IsInSection(deck, sectionId, pos)
	local sectionData, error = self:GetSection(deck, sectionId)
	if not sectionData then
		return false, error
	end

	for _, areaData in pairs(sectionData.Areas) do
		if self:IsInArea(areaData, pos) then
			return true
		end
	end

	return false, "Not in area."
end

function Star_Trek.Sections:IsOnDeck(deck, pos)
	local deckData = self.Decks[deck]
	if istable(deckData) then
		for sectionId, sectionData in pairs(deckData.Sections) do
			if self:IsInSection(deck, sectionId, pos) then
				return true
			end
		end
	else
		return false, "Invalid Deck!"
	end

	return false, "Not on deck."
end

function Star_Trek.Sections:GetInSection(deck, sectionId, filterCallback, allowMap, allowParent)
	local sectionData, error = self:GetSection(deck, sectionId)
	if not sectionData then
		return false, error
	end

	local objects = {}

	for _, areaData in pairs(sectionData.Areas) do
		local pos = areaData.Pos
		local min = areaData.Min
		local max = areaData.Max

		local rotMin = LocalToWorld(pos, Angle(), min, Angle())
		local rotMax = LocalToWorld(pos, Angle(), max, Angle())

		local realMin = Vector(math.min(rotMin[1], rotMax[1]), math.min(rotMin[2], rotMax[2]), math.min(rotMin[3], rotMax[3]))
		local realMax = Vector(math.max(rotMin[1], rotMax[1]), math.max(rotMin[2], rotMax[2]), math.max(rotMin[3], rotMax[3]))

		local potentialEnts = ents.FindInBox(realMin, realMax)
		for _, ent in pairs(potentialEnts) do
			if table.HasValue(objects, ent) then continue end
			if not allowMap and ent:MapCreationID() > -1 then continue end
			if not allowParent and IsValid(ent:GetParent()) then continue end
			if isfunction(filterCallback) and filterCallback(objects, ent) then continue end

			local entPos = ent.EyePos and ent:EyePos() or ent:GetPos()
			if self:IsInArea(areaData, entPos) then
				table.insert(objects, ent)
				ent.DetectedInSection = sectionId
				ent.DetectedOndeck = deck
			end
		end
	end

	return objects
end

function Star_Trek.Sections:GetInSections(deck, sectionIds, filterCallback, allowMap, allowParent)
	local entities = {}

	for _, sectionId in pairs(sectionIds) do
		local sectionEntities = self:GetInSection(deck, sectionId, filterCallback, allowMap, allowParent)
		for _, ent in pairs(sectionEntities) do
			if table.HasValue(entities, ent) then continue end

			table.insert(entities, ent)
		end
	end

	return entities
end

function Star_Trek.Sections:GetSectionName(deck, sectionId)
	local sectionData, error = self:GetSection(deck, sectionId)
	if not sectionData then
		return false, error
	end

	return "Section " .. sectionData.RealId .. " " .. sectionData.Name
end

function Star_Trek.Sections:SetupSections()
	self.Decks = {}

	local globalMin = Vector( math.huge,  math.huge,  math.huge)
	local globalMax = Vector(-math.huge, -math.huge, -math.huge)

	for i = 1, self.DeckCount do
		self.Decks[i] = {
			Sections = {},
		}
	end

	for _, ent in pairs(ents.GetAll()) do
		local name = ent:GetName()
		if not isstring(name) then continue end

		if not string.StartWith(name, "section") then continue end

		local numberData = string.Split(string.sub(ent:GetName(), 8), "_")
		if not istable(numberData) then continue end

		if #numberData < 2 then continue end

		local deck = tonumber(numberData[1])
		if not deck or deck < 1 or deck > self.DeckCount then continue end

		local sectionId = tonumber(numberData[2])
		if not isnumber(sectionId) then
			local number, letter = string.match(numberData[2], "(%d+)(%a)")
			letter = string.byte(letter) - 64

			sectionId = number * 100 + letter
		else
			sectionId = sectionId * 100
		end

		local keyValues = ent.LCARSKeyData
		if istable(keyValues) then
			local sectionName = keyValues["lcars_name"]

			self.Decks[deck].Sections[sectionId] = self.Decks[deck].Sections[sectionId] or {
				Name = sectionName,
				Id = sectionId,
				RealId = numberData[2],
				Areas = {},
			}

			local pos = ent:GetPos()
			if ent:GetAngles() ~= Angle() then
				print("Section Non-Zero Angle Detected! Not implemented!")
			end

			local min, max = ent:GetCollisionBounds()

			table.insert(self.Decks[deck].Sections[sectionId].Areas, {
				Pos = pos,

				Min = min,
				Max = max,
			})

			globalMax = Vector(
				math.max(globalMax.x, pos.x + max.x, pos.x + min.x),
				math.max(globalMax.y, pos.y + max.y, pos.y + min.y),
				math.max(globalMax.z, pos.z + max.z, pos.z + min.z)
			)
			
			globalMin = Vector(
				math.min(globalMin.x, pos.x + max.x, pos.x + min.x),
				math.min(globalMin.y, pos.y + max.y, pos.y + min.y),
				math.min(globalMin.z, pos.z + max.z, pos.z + min.z)
			)
		end

		ent:Remove()
	end

	self.GlobalOffset = globalMin + (globalMax - globalMin) * 0.5
	
	hook.Run("Star_Trek.Sections.Loaded")
end

-- Returns categoriy data for a category_list containing all ship sections.
-- 
-- @param bool? needsLocations
-- @return Table categories
function Star_Trek.Sections:GetSectionCategories(needsLocations)
	local categories = {}
	for deck, deckData in SortedPairs(self.Decks) do
		local category = {
			Name = "DECK " .. deck,
			Buttons = {},
		}

		if table.Count(deckData.Sections) == 0 then
			category.Disabled = true
		else
			for sectionId, sectionData in SortedPairs(deckData.Sections) do
				local button = {
					Name = self:GetSectionName(deck, sectionId),
					Data = sectionData.Id,
				}

				if needsLocations and table.Count(sectionData.BeamLocations) == 0 then
					button.Disabled = true
				end

				table.insert(category.Buttons, button)
			end
		end

		table.insert(categories, category)
	end

	return categories
end

local function setupSections()
	Star_Trek.Sections:SetupSections()
end

hook.Add("InitPostEntity", "Star_Trek.Sections.Setup", setupSections)
hook.Add("PostCleanupMap", "Star_Trek.Sections.Setup", setupSections)
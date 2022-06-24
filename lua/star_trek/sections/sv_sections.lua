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

-- Get the data of the given deck number.
--
-- @param Number deck
-- @return Boolean success
-- @return Table/String deckData/error
function Star_Trek.Sections:GetDeck(deck)
	local deckData = self.Decks[deck]
	if istable(deckData) then
		return true, deckData
	end

	return false, "Invalid Deck!"
end

-- Get the data of the given section.
--
-- @param Number deck
-- @param Number sectionId
-- @return Boolean success
-- @return Table/String sectionData/error
function Star_Trek.Sections:GetSection(deck, sectionId)
	local success, deckData = Star_Trek.Sections:GetDeck(deck)
	if not success then
		return false, deckData
	end

	local sectionData = deckData.Sections[sectionId]
	if istable(sectionData) then
		return true, sectionData
	end

	return false, "Invalid Section Id!"
end

-- Get the full name of the given section.
--
-- @param Number deck
-- @param Number sectionId
function Star_Trek.Sections:GetSectionName(deck, sectionId)
	local success, sectionData = self:GetSection(deck, sectionId)
	if not success then
		return false, sectionData
	end

	return "Section " .. sectionData.RealId .. " " .. sectionData.Name
end

------------------------
--   Position Checks  --
------------------------

-- Determine if the given position is inside the given area.
-- 
-- @param Table areaData
-- @param Vector pos
-- @param Boolean isInside
local function isInArea(areaData, pos)
	local min = areaData.Min
	local max = areaData.Max

	local localPos = areaData.Pos - pos

	if  localPos[1] > min[1] and localPos[1] < max[1]
	and localPos[2] > min[2] and localPos[2] < max[2]
	and localPos[3] > min[3] and localPos[3] < max[3] then
		return true
	end

	return false
end

-- Determine if the given position is inside the given section.
-- 
-- @param Number deck
-- @param Number sectionId
-- @param Vector pos
-- @param Boolean isInside
function Star_Trek.Sections:IsInSection(deck, sectionId, pos)
	local success, sectionData = self:GetSection(deck, sectionId)
	if not success then
		return false
	end

	for _, areaData in pairs(sectionData.Areas) do
		if isInArea(areaData, pos) then
			return true
		end
	end

	return false
end

-- Determine the section a given pos is in.
-- @param Vector pos
-- @return Boolean success
-- @return? Number deck
-- @return? Number sectionId
function Star_Trek.Sections:DetermineSection(pos)
	for deck, deckData in SortedPairs(self.Decks) do
		for sectionId, sectionData in pairs(deckData.Sections) do
			if self:IsInSection(deck, sectionId, pos) then
				return true, deck, sectionId
			end
		end
	end

	return false
end

-- Determine if the given position is inside the sections of the given deck.
-- 
-- @param Number deck
-- @param Vector pos
-- @param Boolean isInside
function Star_Trek.Sections:IsOnDeck(deck, pos)
	local success, deckData = self:GetDeck(deck)
	if not success then
		return false
	end

	for sectionId, sectionData in pairs(deckData.Sections) do
		if self:IsInSection(deck, sectionId, pos) then
			return true
		end
	end

	return false
end

function Star_Trek.Sections:GetInSection(deck, sectionId, filterCallback, allowMap, allowParent)
	local success, sectionData = self:GetSection(deck, sectionId)
	if not success then
		return false, sectionData
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

			local entPos = isfunction(ent.EyePos) and ent:EyePos() or ent:GetPos()
			if isInArea(areaData, entPos) then
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

-- Returns categoriy data for a category_list containing all ship sections.
-- 
-- @param Number? locationMinimum
-- @return Table categories
function Star_Trek.Sections:GetSectionCategories(locationMinimum)
	local categories = {}
	for deck = 1, 15 do
		local category = {
			Name = "DECK " .. deck,
			Buttons = {},
		}

		local success, deckData = self:GetDeck(deck)
		if success then
			for sectionId, sectionData in SortedPairs(deckData.Sections) do
				local button = {
					Name = self:GetSectionName(deck, sectionId),
					Data = sectionData.Id,
				}

				if table.Count(sectionData.BeamLocations) < (locationMinimum or 0) then
					button.Disabled = true
				end

				table.insert(category.Buttons, button)
			end
		else
			category.Disabled = true
		end

		table.insert(categories, category)
	end

	return categories
end

function Star_Trek.Sections:Setup()
	self.Decks = {}

	local globalMin = Vector( math.huge,  math.huge,  math.huge)
	local globalMax = Vector(-math.huge, -math.huge, -math.huge)

	for _, ent in pairs(ents.GetAll()) do
		local name = ent:GetName()
		if not isstring(name) then continue end
		if not string.StartWith(name, "section") then continue end

		local numberData = string.Split(string.sub(ent:GetName(), 8), "_")
		if not istable(numberData) then continue end
		if #numberData < 2 then continue end

		local deck = tonumber(numberData[1])
		if not isnumber(deck) or deck < 1 then continue end
		self.Decks[deck] = self.Decks[deck] or {Sections = {}}

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
			self.Decks[deck].Sections[sectionId] = self.Decks[deck].Sections[sectionId] or {
				Name = keyValues["lcars_name"],
				Id = sectionId,
				RealId = numberData[2],
				Areas = {},
			}

			local pos = ent:GetPos()
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

			if ent:GetAngles() ~= Angle() then
				print("Section Non-Zero Angle Detected! Not implemented!")
			end
		else
			print("Invalid Section Key Values! Skipping Entity!")
		end

		ent:Remove()
	end

	self.GlobalOffset = globalMin + (globalMax - globalMin) * 0.5

	hook.Run("Star_Trek.Sections.Loaded")
end

hook.Add("InitPostEntity", "Star_Trek.Sections.Setup", function() Star_Trek.Sections:Setup() end)
hook.Add("PostCleanupMap", "Star_Trek.Sections.Setup", function() Star_Trek.Sections:Setup() end)
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
-- @param Vector pos
-- @param Vector min
-- @param Vector max
-- @param Boolean isInside
local function isInArea(pos, min, max)
	if  pos[1] > min[1] and pos[1] < max[1]
	and pos[2] > min[2] and pos[2] < max[2]
	and pos[3] > min[3] and pos[3] < max[3] then
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
		if isInArea(pos, areaData.Min, areaData.Max) then
			return true
		end
	end

	return false
end

-- Returns the decks using the bounds.
-- If an overlap is detected it returns a list of possible decks.
--
-- @param Vector pos
-- @param Table decks
function Star_Trek.Sections:FindDecksFast(pos)
	local decks = {}

	for deck, deckData in ipairs(self.Decks) do
		for _, boundData in pairs(deckData.Bounds) do
			if isInArea(pos, boundData.Min, boundData.Max) then
				table.insert(decks, deck)

				-- Stop detection for this deck
				break
			end
		end
	end

	return decks
end

-- Determine the section a given pos is in.
-- @param Vector pos
-- @return Boolean success
-- @return? Number deck
-- @return? Number sectionId
function Star_Trek.Sections:DetermineSection(pos)
	local decks = self:FindDecksFast(pos)

	for _, deck in pairs(decks) do
		local deckData = self.Decks[deck]
		if not istable(deckData) then continue end

		for sectionId, sectionData in pairs(deckData.Sections) do
			for _, areaData in pairs(sectionData.Areas) do
				if isInArea(pos, areaData.Min, areaData.Max) then
					return true, deck, sectionId
				end
			end
		end
	end

	return false
end

function Star_Trek.Sections:GetInSections(deck, sectionIds, filterCallback, allowMap, allowParent)
	local deckData = self.Decks[deck]
	if not istable(deckData) then
		return {}
	end

	local objects = {}

	for _, sectionId in pairs(sectionIds) do
		local sectionData = deckData.Sections[sectionId]
		if not istable(sectionData) then
			continue
		end

		for _, areaData in pairs(sectionData.Areas) do
			local entities = ents.FindInBox(areaData.Min, areaData.Max)

			for _, ent in pairs(entities) do
				if table.HasValue(objects, ent) then continue end
				if not allowMap and ent:MapCreationID() > -1 then continue end
				if not allowParent and IsValid(ent:GetParent()) then continue end
				if isfunction(filterCallback) and filterCallback(objects, ent) then continue end

				table.insert(objects, ent)
				ent.DetectedInSection = sectionId
				ent.DetectedOnDeck = deck
			end
		end
	end

	return objects
end

-- Get entities from the section.
--
-- @param Number deck
-- @param Number sectionId
-- @param function filterCallback
-- @param? Boolean allowMap
-- @param? Boolean allowParent
-- @return Table objects
function Star_Trek.Sections:GetInSection(deck, sectionId, filterCallback, allowMap, allowParent)
	return Star_Trek.Sections:GetInSections(deck, {sectionId}, filterCallback, allowMap, allowParent)
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
					Data = sectionId,
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

-- Add the given Bounds to the table for effiecient detection.
-- Merges Bounds if nearby objects on the height axis.
--
-- @param table bounds
-- @param Vector min
-- @param Vector max
local HEIGHT_THRESHOLD = 162
local function generateBounds(bounds, min, max)
	-- Find existing fitting bounds and ajust if found.
	for _, boundData in pairs(bounds) do
		if max.z - min.z > HEIGHT_THRESHOLD then
			break
		end
		if boundData.Max.z - boundData.Min.z > HEIGHT_THRESHOLD then
			continue
		end

		if not (
		   (boundData.Max.z <= min.z
		and boundData.Max.z <= max.z)
		or (boundData.Min.z >= min.z
		and boundData.Min.z >= max.z)) then
			boundData.Min = Vector(
				math.min(boundData.Min.x, min.x),
				math.min(boundData.Min.y, min.y),
				math.min(boundData.Min.z, min.z)
			)

			boundData.Max = Vector(
				math.max(boundData.Max.x, max.x),
				math.max(boundData.Max.y, max.y),
				math.max(boundData.Max.z, max.z)
			)

			return
		end
	end

	-- Add new bounds table if no fitting has been found.
	local boundData = {}
	boundData.Min = min
	boundData.Max = max
	table.insert(bounds, boundData)
end

function Star_Trek.Sections:Setup()
	self.Decks = {}

	local globalMin = Vector( math.huge,  math.huge,  math.huge)
	local globalMax = Vector(-math.huge, -math.huge, -math.huge)

	for _, ent in pairs(ents.GetAll()) do
		-- Get the name of the entity.
		local name = ent:GetName()
		if not isstring(name) then continue end
		if not string.StartWith(name, "section") then continue end

		local keyValues = ent.LCARSKeyData
		if not istable(keyValues) then
			Star_Trek:Message("Invalid Section Key Values! Skipping Entity!")
			continue
		end

		if ent:GetAngles() ~= Angle() then
			Star_Trek:Message("Section Non-Zero Angle Detected! Not implemented!")
			continue
		end

		-- Get the part of the entity name, that determines the deck and sectionId
		local numberData = string.Split(string.sub(ent:GetName(), 8), "_")
		if not istable(numberData) then continue end
		if #numberData < 2 then continue end

		-- Generate the deck number from the name of the entity.
		local deck = tonumber(numberData[1])
		if not isnumber(deck) or deck < 1 then continue end

		-- Create the deckData table, if it doesnt exist yet.
		local deckData = self.Decks[deck]
		if not istable(deckData) then
			deckData = {}
			deckData.Sections = {}
			deckData.Bounds = {}

			self.Decks[deck] = deckData
		end

		-- Generate the section id from the name of the entity.
		local realId = numberData[2]
		local sectionId = tonumber(realId)
		if not isnumber(sectionId) then
			local number, letter = string.match(realId, "(%d+)(%a)")
			letter = string.byte(letter) - 64

			sectionId = number * 100 + letter
		else
			sectionId = sectionId * 100
		end

		-- Create the sectionData table, if it doesnt exist yet.
		local sectionData = deckData.Sections[sectionId]
		if not istable(sectionData) then
			sectionData = {}
			sectionData.RealId = realId
			sectionData.Name = keyValues["lcars_name"] or "Section " .. sectionId

			sectionData.Areas = {}

			deckData.Sections[sectionId] = sectionData
		end

		-- Generate the areaData table.
		local pos = ent:GetPos()
		local min, max = ent:GetCollisionBounds()
		min = pos + min
		max = pos + max

		-- Rounding because one section is offset.
		-- Can be removed if map is updated.
		min = Vector(
			math.Round(min.x, 0),
			math.Round(min.y, 0),
			math.Round(min.z, 0)
		)
		max = Vector(
			math.Round(max.x, 0),
			math.Round(max.y, 0),
			math.Round(max.z, 0)
		)

		-- Fixing engineering overlapping with jeffries
		local h = max.z - min.z
		if deck == 11 and sectionId == 400 and h == 258 then
			max.z = max.z - 64
		end

		local areaData = {}
		areaData.Min = min
		areaData.Max = max
		table.insert(sectionData.Areas, areaData)

		-- Generate the bounds of the deck
		generateBounds(deckData.Bounds, min, max)

		-- Generate global bounds for offset detection.
		globalMin = Vector(
			math.min(globalMin.x, min.x),
			math.min(globalMin.y, min.y),
			math.min(globalMin.z, min.z)
		)
		globalMax = Vector(
			math.max(globalMax.x, max.x),
			math.max(globalMax.y, max.y),
			math.max(globalMax.z, max.z)
		)

		SafeRemoveEntity(ent)
	end

	-- Calculate offset for jeffries tubes bounds.
	local deck11Data = self.Decks[11]
	if istable(deck11Data) then
		local deck11Z
		for _, boundData in pairs(deck11Data.Bounds) do
			local z = boundData.Min.z
			local h = boundData.Max.z - z
			if h == 162 and z > 1000 then
				deck11Z = z

				break
			end
		end

		-- Add Bounds for jeffries tubes detection.
		self.JBounds = {}
		for deck = 1, 11 do
			local jBounds = {
				Min = Vector(globalMin),
				Max = Vector(globalMax),
			}

			jBounds.Min.z = deck11Z + (11 - deck) * 162
			jBounds.Max.z = jBounds.Min.z + 162

			self.JBounds[deck] = jBounds
		end
	end

	self.GlobalOffset = globalMin + (globalMax - globalMin) * 0.5

	hook.Run("Star_Trek.Sections.Loaded")
end

hook.Add("InitPostEntity", "Star_Trek.Sections.Setup", function() Star_Trek.Sections:Setup() end)
hook.Add("PostCleanupMap", "Star_Trek.Sections.Setup", function() Star_Trek.Sections:Setup() end)
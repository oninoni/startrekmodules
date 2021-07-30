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
	-- TODO: No idea why there needs to be a "-" here!

	if  localPos[1] > min[1] and localPos[1] < max.x
	and localPos[2] > min[2] and localPos[2] < max.y
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

		local realMin = Vector(math.min(rotMin.x, rotMax.x), math.min(rotMin.y, rotMax.y), math.min(rotMin.z, rotMax.z))
		local realMax = Vector(math.max(rotMin.x, rotMax.x), math.max(rotMin.y, rotMax.y), math.max(rotMin.z, rotMax.z))

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
		end

		ent:Remove()
	end

	hook.Run("Star_Trek.Sections.Loaded")
end

local function setupSections()
	Star_Trek.Sections:SetupSections()
end

hook.Add("InitPostEntity", "Star_Trek.Sections.Setup", setupSections)
hook.Add("PostCleanupMap", "Star_Trek.Sections.Setup", setupSections)
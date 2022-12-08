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
--       Force Fields | Server       --
---------------------------------------

-- Enables the given force field.
--
-- @param Table forceFieldData
-- @return Boolean success
-- @return Vector pos
function Star_Trek.ForceFields:EnableForceField(forceFieldData, force)
	if not istable(forceFieldData) then
		return false
	end

	if not force and forceFieldData.AlwaysOn then
		return false
	end

	if IsValid(forceFieldData.Entity) then
		return false
	end

	-- Prevent moving if broken / disabled.
	if not force and Star_Trek.Control:GetStatus("force_fields", forceFieldData.Deck, forceFieldData.SectionId) ~= Star_Trek.Control.ACTIVE then
		return false
	end

	local ent = ents.Create("force_field")
	ent:SetModel(forceFieldData.Model)
	ent:SetPos(forceFieldData.Pos)
	ent:SetAngles(forceFieldData.Ang)

	if forceFieldData.AlwaysOn then
		ent:SetAlwaysOn(true)
	end

	ent:Spawn()
	ent:Activate()

	forceFieldData.Entity = ent
	ent.ForceFieldData = forceFieldData

	self:EnableForceField(forceFieldData.Partner)

	return true, ent:GetPos()
end

-- Change use to use success.
function Star_Trek.ForceFields:EnableForceFieldsInSections(deck, sectionIds)
	local positions = {}

	local success, deckData = Star_Trek.Sections:GetDeck(deck)
	if not success then return false, deckData end

	for _, sectionId in pairs(sectionIds or {}) do
		local sectionData = deckData.Sections[sectionId]
		if not istable(sectionData) then
			continue
		end

		for _, forceFieldData in pairs(sectionData.ForceFields or {}) do
			local success2, pos = self:EnableForceField(forceFieldData)
			if success2 then
				table.insert(positions, {
					SectionId = sectionId,
					Deck = deck,

					Pos = pos,
				})
			end
		end
	end

	return true, positions
end

-- Enables the named force fields.
--
-- @param String name
function Star_Trek.ForceFields:EnableNamedForceField(name)
	for _, forceFieldData in pairs(self.NamedForceFields[name] or {}) do
		self:EnableForceField(forceFieldData)
	end
end

-- Disables the given force field.
--
-- @param Table forceFieldData
-- @return Boolean success
-- @return Vector pos
function Star_Trek.ForceFields:DisableForceField(forceFieldData)
	if not istable(forceFieldData) then
		return false
	end

	if forceFieldData.AlwaysOn then
		return false
	end

	local ent = forceFieldData.Entity
	if not IsValid(ent) then
		return false
	end

	local pos = ent:GetPos()

	SafeRemoveEntity(ent)
	forceFieldData.Entity = nil

	self:DisableForceField(forceFieldData.Partner)

	return true, pos
end

-- Change use to use success.
function Star_Trek.ForceFields:DisableForceFieldsInSections(deck, sectionIds)
	local positions = {}

	local success, deckData = Star_Trek.Sections:GetDeck(deck)
	if not success then return false, deckData end

	for _, sectionId in pairs(sectionIds or {}) do
		local sectionData = deckData.Sections[sectionId]
		if not istable(sectionData) then
			continue
		end

		for _, forceFieldData in pairs(sectionData.ForceFields or {}) do
			local success2, pos = self:DisableForceField(forceFieldData)
			if success2 then
				table.insert(positions, {
					SectionId = sectionId,
					Deck = deck,

					Pos = pos,
				})
			end
		end
	end

	return true, positions
end

-- Disables the named force fields.
--
-- @param String name
function Star_Trek.ForceFields:DisableNamedForceField(name)
	for _, forceFieldData in pairs(self.NamedForceFields[name] or {}) do
		self:DisableForceField(forceFieldData)
	end
end

Star_Trek.Control:Register("force_fields", "Forcefields", function(value, deck, sectionId)
	if value == Star_Trek.Control.ACTIVE then
		return
	end

	for _, forceFieldData in pairs(Star_Trek.ForceFields.ForceFields) do
		if (isnumber(deck) and isnumber(sectionId))
		and (forceFieldData.Deck ~= deck or forceFieldData.SectionId ~= sectionId) then
			continue
		end

		if isnumber(deck)
		and forceFieldData.Deck ~= deck then
			continue
		end

		Star_Trek.ForceFields:DisableForceField(forceFieldData)
	end
end)

function Star_Trek.Security:CheckIsolatedPos(pos)
	local success, deck, sectionId = Star_Trek.Sections:DetermineSection(pos)
	if not success then
		return false
	end

	local _, sectionData = Star_Trek.Sections:GetSection(deck, sectionId)

	for _, forceFieldData in pairs(sectionData.ForceFields) do
		if not IsValid(forceFieldData.Entity) then

			return false
		end
	end

	return true, Star_Trek.Sections:GetSectionName(deck, sectionId)
end

hook.Add("Star_Trek.Transporter.BlockBeamTo", "Star_Trek.Transporter.CheckForcefields", function(pos)
	local isIsolated, sectionName = Star_Trek.Security:CheckIsolatedPos(pos)
	if isIsolated then
		return true, sectionName .. " is locked down using forcefields."
	end

	return false
end)

-------------
--- Setup ---
-------------

function Star_Trek.ForceFields:SetupForceField(ent, deck, sectionId)
	local forceFieldData = {
		Pos = ent:GetPos(),
		Ang = ent:GetAngles(),

		Deck = deck,
		SectionId = sectionId,

		Model = ent:GetModel(),
		Entity = ent,
	}

	local keyValues = ent.LCARSKeyData
	if istable(keyValues) then
		local name = keyValues["lcars_forcefield_name"]
		if isstring(name) and name ~= "" then
			forceFieldData.Name = name

			self.NamedForceFields[name] = self.NamedForceFields[name] or {}

			table.insert(self.NamedForceFields[name], forceFieldData)
		end

		local alwaysOn = keyValues["lcars_forcefield_alwayson"]
		if isstring(alwaysOn) and alwaysOn == "1" then
			forceFieldData.AlwaysOn = true
		end
	end

	ent.ForceFieldData = forceFieldData
	table.insert(self.ForceFields, forceFieldData)

	return forceFieldData
end

function Star_Trek.ForceFields:SetUpPortalForceField(forceField)
	local forceFieldData = forceField.ForceFieldData
	if not istable(forceFieldData) then
		return
	end

	local sourceEntities = ents.FindInSphere(forceField:GetPos(), 8)
	for _, portal in pairs(sourceEntities) do
		if portal:GetClass() ~= "linked_portal_door" then
			continue
		end

		local targetPortal = portal:GetExit()
		if not IsValid(targetPortal) then
			continue
		end

		local targetEntities = ents.FindInSphere(targetPortal:GetPos(), 8)
		for _, partnerForceField in pairs(targetEntities) do
			if partnerForceField:GetName() == "lcars_forcefield" then
				local partnerForceFieldData = partnerForceField.ForceFieldData
				if not istable(partnerForceFieldData) then
					continue
				end

				partnerForceFieldData.Partner = forceFieldData
				forceFieldData.Partner = partnerForceFieldData

				return
			end
		end
	end
end

hook.Add("Star_Trek.Sections.Loaded", "Star_Trek.ForceFields.DetectForceFields", function()
	Star_Trek.ForceFields.ForceFields = {}
	Star_Trek.ForceFields.NamedForceFields = {}

	for deck, deckData in pairs(Star_Trek.Sections.Decks) do
		for sectionId, sectionData in pairs(deckData.Sections) do
			sectionData.ForceFields = {}
			local objects = Star_Trek.Sections:GetInSection(deck, sectionId, function(object)
				if not object.StrictInside then
					return true
				end

				local ent = object.Entity
				if ent:GetName() ~= "lcars_forcefield" then
					return true
				end

			end, true)

			for _, object in pairs(objects) do
				local ent = object.Entity
				table.insert(sectionData.ForceFields, Star_Trek.ForceFields:SetupForceField(ent, deck, sectionId))
			end
		end
	end

	local forceFields = ents.FindByName("lcars_forcefield")
	-- Fallback for Force Fields outside of Sections.
	-- Not currently needed for rp_intrepid_v1
	for _, ent in pairs(forceFields) do
		if not ent.ForceFieldData then
			Star_Trek.ForceFields:SetupForceField(ent)
		end
	end

	-- Setup Portal Connections between force fields.
	for _, ent in pairs(forceFields) do
		Star_Trek.ForceFields:SetUpPortalForceField(ent)
	end

	-- Delete all the map force field marker entities.
	for _, ent in pairs(forceFields) do
		ent.ForceFieldData.Entity = nil
		SafeRemoveEntity(ent)
	end

	-- Enable Always On Forcefields
	for _, forceFieldData in pairs(Star_Trek.ForceFields.ForceFields) do
		if forceFieldData.AlwaysOn then
			Star_Trek.ForceFields:EnableForceField(forceFieldData, true)
		end
	end
end)
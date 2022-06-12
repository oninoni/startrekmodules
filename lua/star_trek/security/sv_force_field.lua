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
--   Security Force Fields | Server  --
---------------------------------------

-- Enables the given force field.
--
-- @param Table forceFieldData
-- @return Boolean success
-- @return Vector pos
function Star_Trek.Security:EnableForceField(forceFieldData, force)
	if not istable(forceFieldData) then
		return false
	end

	if not force and forceFieldData.AlwaysOn then
		return false
	end

	if IsValid(forceFieldData.Entity) then
		return false
	end

	local ent = ents.Create("force_field")
	ent:SetModel(forceFieldData.Model)
	ent:SetPos(forceFieldData.Pos)
	ent:SetAngles(forceFieldData.Ang)

	if forceFieldData.AlwaysOn then
		ent.PreventToggleSound = true
	end

	ent:Spawn()
	ent:Activate()

	forceFieldData.Entity = ent
	ent.ForceFieldData = forceFieldData

	Star_Trek.Security:EnableForceField(forceFieldData.Partner)

	return true, ent:GetPos()
end

-- Change use to use success.
function Star_Trek.Security:EnableForceFieldsInSections(deck, sectionIds)
	local positions = {}

	local deckData = Star_Trek.Sections.Decks[deck]
	if not istable(deckData) then
		return false
	end

	for _, sectionId in pairs(sectionIds or {}) do
		local sectionData = deckData.Sections[sectionId]
		if not istable(sectionData) then
			continue
		end

		for _, forceFieldId in pairs(sectionData.ForceFields or {}) do
			local forceFieldData = self.ForceFields[forceFieldId]
			local success, pos = self:EnableForceField(forceFieldData)
			if success then
				table.insert(positions, {
					DetectedInSection = sectionId,
					DetectedOndeck = deck,

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
function Star_Trek.Security:EnableNamedForceField(name)
	for _, forceFieldData in pairs(self.NamedForceFields[name] or {}) do
		self:EnableForceField(forceFieldData)
	end
end

-- Disables the given force field.
--
-- @param Table forceFieldData
-- @return Boolean success
-- @return Vector pos
function Star_Trek.Security:DisableForceField(forceFieldData)
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

	Star_Trek.Security:DisableForceField(forceFieldData.Partner)

	return true, pos
end

-- Change use to use success.
function Star_Trek.Security:DisableForceFieldsInSections(deck, sectionIds)
	local positions = {}

	local deckData = Star_Trek.Sections.Decks[deck]
	if not istable(deckData) then
		return false
	end

	for _, sectionId in pairs(sectionIds or {}) do
		local sectionData = deckData.Sections[sectionId]
		if not istable(sectionData) then
			continue
		end

		for _, forceFieldId in pairs(sectionData.ForceFields or {}) do
			local forceFieldData = self.ForceFields[forceFieldId]
			local success, pos = self:DisableForceField(forceFieldData)
			if success then
				table.insert(positions, {
					DetectedInSection = sectionId,
					DetectedOndeck = deck,

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
function Star_Trek.Security:DisableNamedForceField(name)
	for _, forceFieldData in pairs(self.NamedForceFields[name] or {}) do
		self:DisableForceField(forceFieldData)
	end
end

-------------
--- Setup ---
-------------

function Star_Trek.Security:SetupForceField(ent)
	local forceFieldData = {
		Pos = ent:GetPos(),
		Ang = ent:GetAngles(),

		Model = ent:GetModel(),
		Entity = ent,
	}

	local keyValues = ent.LCARSKeyData
	if istable(keyValues) then
		local name = keyValues["lcars_forcefield_name"]
		if isstring(name) and name ~= "" then
			forceFieldData.Name = name

			Star_Trek.Security.NamedForceFields[name] = Star_Trek.Security.NamedForceFields[name] or {}

			table.insert(Star_Trek.Security.NamedForceFields[name], forceFieldData)
		end

		local alwaysOn = keyValues["lcars_forcefield_alwayson"]
		if isstring(alwaysOn) and alwaysOn == "1" then
			forceFieldData.AlwaysOn = true
		end
	end

	ent.ForceFieldData = forceFieldData

	local id = table.insert(self.ForceFields, forceFieldData)
	forceFieldData.ForceFieldId = id

	return id
end

function Star_Trek.Security:SetUpPortalForceField(forceField)
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

hook.Add("Star_Trek.Sections.Loaded", "Star_Trek.Security.DetectForceFields", function()
	Star_Trek.Security.ForceFields = {}
	Star_Trek.Security.NamedForceFields = {}

	for deck, deckData in pairs(Star_Trek.Sections.Decks) do
		for sectionId, sectionData in pairs(deckData.Sections) do
			sectionData.ForceFields = {}
			local entities = Star_Trek.Sections:GetInSection(deck, sectionId, function(objects, ent)
				if ent:GetName() ~= "lcars_forcefield" then
					return true
				end
			end, true)

			for _, ent in pairs(entities) do
				local id = Star_Trek.Security:SetupForceField(ent)

				table.insert(sectionData.ForceFields, id)
			end
		end
	end

	local forceFields = ents.FindByName("lcars_forcefield")
	for _, ent in pairs(forceFields) do
		if not ent.ForceFieldData then
			Star_Trek.Security:SetupForceField(ent)
		end
	end
	for _, ent in pairs(forceFields) do
		Star_Trek.Security:SetUpPortalForceField(ent)
	end
	for _, ent in pairs(forceFields) do
		ent.ForceFieldData.Entity = nil
		SafeRemoveEntity(ent)
	end

	-- Enable Always On Forcefields
	for _, forceFieldData in pairs(Star_Trek.Security.ForceFields) do
		if forceFieldData.AlwaysOn then
			Star_Trek.Security:EnableForceField(forceFieldData, true)
		end
	end
end)
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
--        Force Field | Server       --
---------------------------------------

local function loadForceField(deck, sectionId, models)
	local forceFields = {}

	for modelName, data in pairs(models) do
		local props = Star_Trek.Util:GetStaticPropsByModel(modelName, function(entry)
			local s, _ = Star_Trek.Sections:IsInSection(deck, sectionId, entry.Origin)

			if s then
				return true
			end

			return false
		end)

		forceFields[modelName] = {
			Props = props,
			Data = data,
		}
	end

	return forceFields
end

hook.Add("Star_Trek.Util.MapLoaded", "Star_Trek.Force_Field.Load", function()
	timer.Simple(0, function()
		for deck, deckData in pairs(Star_Trek.Sections.Decks) do
			for sectionId, sectionData in pairs(deckData.Sections) do
				sectionData.FrameForceFields = loadForceField(deck, sectionId, Star_Trek.Force_Field.FrameModels)
				sectionData.ActiveForceFields = {}
			end
		end
	end)
end)

function Star_Trek.Force_Field:Enable(deck, sectionId)
	local sectionData, error = Star_Trek.Sections:GetSection(deck, sectionId)
	if not sectionData then
		return false, error
	end

	if table.Count(sectionData.ActiveForceFields) > 0 then
		return false, "Already Active"
	end

	local positions = {}

	for modelName, force_fields in pairs(sectionData.FrameForceFields) do
		for _, staticProp in pairs(force_fields.Props) do -- Probably bad, because only allows one type at once.
			local pos, ang = LocalToWorld(force_fields.Data.Pos, force_fields.Data.Ang, staticProp.Origin, staticProp.Angles)

			local ent = ents.Create("prop_physics")
			ent:SetModel(force_fields.Data.Model)
			ent:SetMaterial("models/props_combine/stasisshield_sheet")
			ent:SetPos(pos)
			ent:SetAngles(ang)

			ent:Spawn()
			ent:Activate()

			ent:SetPersistent(true)

			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end

			table.insert(positions, pos)
			table.insert(sectionData.ActiveForceFields, ent)
		end
	end

	return true, positions
end

function Star_Trek.Force_Field:EnableSections(deck, sectionIds)
	local positions = {}
	for _, sectionId in pairs(sectionIds) do
		local success, sectionPositions = Star_Trek.Force_Field:Enable(deck, sectionId)
		if not success then
			return false, sectionPositions
		end

		for _, pos in pairs(sectionPositions) do
			table.insert(positions, {
				Pos = pos,
				DetectedInSection = sectionId,
			})
		end
	end

	return positions
end

function Star_Trek.Force_Field:Disable(deck, sectionId)
	local sectionData, error = Star_Trek.Sections:GetSection(deck, sectionId)
	if not sectionData then
		return false, error
	end

	local positions = {}

	for _, ent in pairs(sectionData.ActiveForceFields) do
		table.insert(positions, ent:GetPos())
		ent:Remove()
	end

	sectionData.ActiveForceFields = {}

	return true, positions
end

function Star_Trek.Force_Field:DisableSections(deck, sectionIds)
	local positions = {}
	for _, sectionId in pairs(sectionIds) do
		local success, sectionPositions = Star_Trek.Force_Field:Disable(deck, sectionId)
		if not success then
			return false, sectionPositions
		end

		for _, pos in pairs(sectionPositions) do
			table.insert(positions, {
				Pos = pos,
				DetectedInSection = sectionId,
			})
		end
	end

	return positions
end
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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--          Damage | Server          --
---------------------------------------

function Star_Trek.Damage:Setup()
	self.StaticPropModels = {}
	self.ModelToDamageType = {}

	-- Create the list of relevant models.
	for damageType, damageTypeData in pairs(self.DamageTypes or {}) do
		for model, _ in pairs(damageTypeData.StaticProps) do
			if not table.HasValue(self.StaticPropModels, model) then
				table.insert(self.StaticPropModels, model)
			end

			self.ModelToDamageType[model] = self.ModelToDamageType[model] or {}
			table.insert(self.ModelToDamageType[model], damageType)
		end
	end

	-- Initialise a list of static props for every section.
	local staticProps = Star_Trek.Util:GetStaticPropsByModelList(self.StaticPropModels)
	for _, staticProp in pairs(staticProps) do
		local pos = staticProp.Origin
		local ang = staticProp.Angles
		local model = staticProp.PropType

		local success, deck, sectionId = Star_Trek.Sections:DetermineSection(pos)
		if success then
			local success2, sectionData = Star_Trek.Sections:GetSection(deck, sectionId)
			if not success2 then
				continue
			end

			--[[
			sectionData.DamageStaticProps = sectionData.DamageStaticProps or {}
			sectionData.DamageStaticProps[model] = sectionData.DamageStaticProps[model] or {}
			local damageStaticProp = {}

			damageStaticProp.Pos = pos
			damageStaticProp.Ang = ang

			table.insert(sectionData.DamageStaticProps[model], damageStaticProp)
			]]

			sectionData.DamageTypes = sectionData.DamageTypes or {}
			for _, damageType in pairs(self.ModelToDamageType[model] or {}) do
				local damageTypeData = self.DamageTypes[damageType]

				for _, location in pairs(damageTypeData.StaticProps[model].Locations) do
					local lPos, lAng = LocalToWorld(location.Pos, location.Ang, pos, ang)
					debugoverlay.Axis(lPos, lAng, 10, 10, true)
				end
			end
		end
	end
end

hook.Add("Star_Trek.Util.MapLoaded", "Star_Trek.Damage.Initialize", function()
	Star_Trek.Damage:Setup()
end)

--[[

function Star_Trek.Damage:DamageSection(deck, sectionId, damageType)
	local damageTypeData = Star_Trek.Damage.DamageTypes[damageType]
	if not (istable(damageTypeData) and istable(damageTypeData.StaticProps)) then
		return false, "Invalid damage type!"
	end

	local modelList = {}
	for model, staticPropData in pairs(damageTypeData.StaticProps) do
		table.insert(modelList, model)
	end

	local staticProps = Star_Trek.Util:GetStaticPropsByModelList(modelList, function(entry)
		local s, _ = Star_Trek.Sections:IsInSection(deck, sectionId, entry.Origin)

		if s then
			return true
		end

		return false
	end)

	if table.Count(staticProps) == 0 then
		return false, "No position for damage found!"
	end

	local staticProp
	for _, sProp in RandomPairs(staticProps) do
		if not IsValid(sProp.Damaged[damageType]) then
			staticProp = sProp
			break
		end
	end

	if not istable(staticProp) then
		return false, "No undamaged position for damage found!"
	end

	local staticPropData = damageTypeData.StaticProps[staticProp.PropType]
	local location = table.Random(staticPropData.Locations)

	local ent = ents.Create(damageTypeData.Entity)

	local pos, ang = LocalToWorld(location.Pos, location.Ang, staticProp.Origin, staticProp.Angles)
	ent:SetPos(pos)
	ent:SetAngles(ang)

	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	ent.StaticProp = staticProp
	staticProp.Damaged[damageType] = ent

	return true
end

hook.Add("Star_Trek.Util.MapLoaded", "Star_Trek.Damage.Initialize", function()
	for _, lump_entry in pairs(Star_Trek.Util.MapData.static_props) do
		for _, entry in pairs(lump_entry.entries) do
			entry.Damaged = {}
		end
	end

	timer.Simple(0, function()
	end)
end)
]]
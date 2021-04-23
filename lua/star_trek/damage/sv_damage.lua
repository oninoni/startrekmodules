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
--          Damage | Server          --
---------------------------------------

-- TODO: Rewrite Caching on Star_Trek.Util.MapLoaded + Star_Trek.Sections.Loaded with the Positions preloaded per Type.

function Star_Trek.Damage:DamageSection(damageType, deck, sectionId)
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
end

hook.Add("Star_Trek.Util.MapLoaded", "Star_Trek.Damage.Initialize", function()
	for _, lump_entry in pairs(Star_Trek.Util.MapData.static_props) do
		for _, entry in pairs(lump_entry.entries) do
			entry.Damaged = {}
		end
	end
end)

--Star_Trek.Damage:DamageSection("eps_breach", 1, 400)
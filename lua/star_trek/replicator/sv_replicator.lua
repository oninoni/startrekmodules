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
--        Replicator | Server        --
---------------------------------------

function Star_Trek.Replicator:GetReplicatorList(ent)
	local categories = table.Copy(Star_Trek.Replicator.Categories)

	for _, category in pairs(categories) do
		local name = category.Name
		if category.Disabled then
			local keyValues = ent.LCARSKeyData
			if istable(keyValues) and keyValues["lcars_" .. string.lower(name) .. "_unlock"] then
				category.Disabled = false
			end
		else
			local keyValues = ent.LCARSKeyData
			if istable(keyValues) and keyValues["lcars_" .. string.lower(name) .. "_lock"] then
				category.Disabled = true
			end
		end
	end

	return categories
end

function Star_Trek.Replicator:CreateObject(data, pos, angle)
	local class = "prop_physics"
	local model = data

	if istable(data) then
		class = data.Class or class
		model = data.Model or false
	end

	local ent = ents.Create(class)
	if IsValid(ent) then
		if model then
			ent:SetModel(model)
		end

		ent:SetPos(pos)
		ent:SetAngles(angle)
		local renderMode = ent:GetRenderMode()
		ent:SetRenderMode(RENDERMODE_NONE)

		ent:Spawn()
		ent:Activate()

		local phys = ent:GetPhysicsObject()
		local motion
		if IsValid(phys) then
			motion = phys:IsMotionEnabled()
			phys:EnableMotion(false)
		end

		timer.Simple(1, function()
			if not IsValid(ent) then return end

			ent:SetRenderMode(renderMode)

			local phys2 = ent:GetPhysicsObject()
			if IsValid(phys2) then
				phys2:EnableMotion(motion)
			end

			ent.Replicated = true

			Star_Trek.Transporter:TransportObject("replicator", ent, pos, true, false)
		end)

		return true
	end

	return false, "Unknown Replicator Object"
end

Star_Trek.Replicator.RecycleList = Star_Trek.Replicator.RecycleList or {}
timer.Create("Star_Trek.Replicator.Recycle", 1, 0, function()
	local toBeRemoved = {}

	for _, ent in pairs(Star_Trek.Replicator.RecycleList) do
		if ent.BufferData then
			table.insert(toBeRemoved, ent)
		end
	end

	for _, ent in pairs(toBeRemoved) do
		table.RemoveByValue(Star_Trek.Replicator.RecycleList, ent)
	end
end)

function Star_Trek.Replicator:RecycleObject(ent)
	if not ent.Replicated then return end
	table.insert(self.RecycleList, ent)

	Star_Trek.Transporter:TransportObject("replicator", ent, ent:GetPos(), false, true, function(transporterCycle)
		local state = transporterCycle.State
		if state == 2 then
			transporterCycle.Entity:Remove()
		end
	end)
end

-- Scan Replicated Matter
hook.Add("Star_Trek.Sensors.ScanEntity", "Sensors.CheckReplicated", function(ent, scanData)
	if ent.Replicated then
		scanData.Replicated = true
	end
end)

hook.Add("PlayerCanPickupItem", "Star_Trek.Replicator.PreventPickup", function(ply, ent)
	if ent.Replicated and not (ply:KeyDown(IN_USE) and ply:GetEyeTrace().Entity == ent) then
		return false
	end
end)

hook.Add("PlayerCanPickupItem", "Star_Trek.Replicator.PreventPickup", function(ply, ent)
	if ent.Replicated and not (ply:KeyDown(IN_USE) and ply:GetEyeTrace().Entity == ent) then
		return false
	end
end)
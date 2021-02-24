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
--        Replicator | Server        --
---------------------------------------

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

		local min, _ = ent:GetCollisionBounds()
		ent:SetPos(pos - Vector(0, 0, min.z))
		ent:SetAngles(angle)

		ent:Spawn()
		ent:Activate()

		ent.Replicated = true

		local transportData = {
			Object = ent,
			TargetPos = ent:GetPos(),
			StateTime = CurTime(),
			State = 3,
			ToBuffer = false,
		}

		for _, activeTransportData in pairs(Star_Trek.Transporter.ActiveTransports) do
			if activeTransportData.Object == ent then
				return false, "Replicator Active"
			end
		end

		if ent.BufferData then
			transportData = ent.BufferData
			ent.BufferData = nil

			transportData.TargetPos = targetPos or ent:GetPos()
			transportData.TargetPad = targetPad
			transportData.ToBuffer = false
		else
			ent:SetRenderMode(RENDERMODE_NONE)

			transportData.OldMoveType = ent:GetMoveType()
			ent:SetMoveType(MOVETYPE_NONE)

			transportData.OldColor = ent:GetColor()
			ent:SetColor(ColorAlpha(transportData.OldColor, 0))

			Star_Trek.Transporter:TriggerEffect(transportData, ent)
			Star_Trek.Transporter:BroadcastEffect(ent, true, true)
		end

		table.insert(Star_Trek.Transporter.ActiveTransports, transportData)

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

	local transportData = {
		Object = ent,
		TargetPos = pos,
		StateTime = CurTime(),
		State = 1,
		ToBuffer = true,
	}

	for _, activeTransportData in pairs(Star_Trek.Transporter.ActiveTransports) do
		if activeTransportData.Object == ent then return end
	end

	if ent.BufferData then
		transportData = ent.BufferData
		ent.BufferData = nil

		transportData.TargetPos = targetPos or ent:GetPos()
		transportData.TargetPad = targetPad
		transportData.ToBuffer = false
	else
		Star_Trek.Transporter:TriggerEffect(transportData, ent)
		Star_Trek.Transporter:BroadcastEffect(ent, false, true)
	end

	table.insert(Star_Trek.Transporter.ActiveTransports, transportData)
end
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
--     Transporter Cycle | Server    --
---------------------------------------

Star_Trek.Transporter.ActiveTransports = Star_Trek.Transporter.ActiveTransports or {}

util.AddNetworkString("Star_Trek.Transporter.TriggerEffect")

-- Applies the serverside effects to the entity depending on the current state of the transport cycle.
--
-- @param Table transportData
-- @param Entity ent
function Star_Trek.Transporter:TriggerEffect(transportData, ent)
	local mode = transportData.State

	if mode == 1 then
		transportData.OldRenderMode = ent:GetRenderMode()
		ent:SetRenderMode(RENDERMODE_TRANSTEXTURE)

		transportData.OldCollisionGroup = ent:GetCollisionGroup()
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		if ent:IsPlayer() then
			ent:Freeze(true)
		else
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				transportData.OldMotionEnabled = phys:IsMotionEnabled()
				phys:EnableMotion(false)
			end
		end

		local lowerBounds = ent:GetCollisionBounds()
		transportData.ZOffset = -lowerBounds.Z + 2 -- Offset to prevent stucking in floor

		ent:DrawShadow(false)

		for _, child in pairs(ent:GetChildren()) do
			child.OldRenderMode = child:GetRenderMode()
			child:SetRenderMode(RENDERMODE_TRANSTEXTURE)

			child.OldColor = child:GetColor()
			child:SetColor(Color(255, 255, 255, 0))
		end

	elseif mode == 2 then
		ent:SetRenderMode(RENDERMODE_NONE)
		
		ent:SetCollisionGroup(transportData.OldCollisionGroup)

		transportData.OldMoveType = ent:GetMoveType()
		ent:SetMoveType(MOVETYPE_NONE)

		transportData.OldColor = ent:GetColor()
		ent:SetColor(ColorAlpha(transportData.OldColor, 0))
	elseif mode == 3 then
		ent:SetRenderMode(RENDERMODE_TRANSTEXTURE)
		
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		ent:SetPos((transportData.TargetPos or ent:GetPos()) + Vector(0, 0, transportData.ZOffset))
	else
		if transportData.OldColor ~= nil then
			ent:SetColor(transportData.OldColor)
		end

		if transportData.OldRenderMode ~= nil then
			ent:SetRenderMode(transportData.OldRenderMode)
		end

		if transportData.OldCollisionGroup ~= nil then
			ent:SetCollisionGroup(transportData.OldCollisionGroup)
		end

		if transportData.OldMoveType ~= nil then
			ent:SetMoveType(transportData.OldMoveType)
		end

		-- Make sure Position is set properly.
		-- Looks strange but is needed. (Probably a bug with setting the Move Type back)
		ent:SetPos(ent:GetPos())

		if ent:IsPlayer() then
			ent:Freeze(false)
		else
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				if transportData.OldMotionEnabled ~= nil then
					phys:EnableMotion(transportData.OldMotionEnabled)
				end

				phys:Wake()
			end
		end

		ent:DrawShadow(true)

		for _, child in pairs(ent:GetChildren()) do
			if child.OldRenderMode ~= nil then
				child:SetRenderMode(child.OldRenderMode)
			end

			child.OldRenderMode = nil

			child:SetColor(child.OldColor)
			child.OldColor = nil
		end

		ent:Activate()
	end
end

-- Sets up and executes the clientside transporter effect.
--
-- @param Entity ent
-- @param Boolean remat
-- @param? Boolean replicator
function Star_Trek.Transporter:BroadcastEffect(ent, remat, replicator, targetPos)
	if not IsValid(ent) then return end

	targetPos = targetPos or Vector()

	local oldCollisionGroup = ent:GetCollisionGroup()
	ent:SetCollisionGroup(COLLISION_GROUP_NONE)

	ent:SetCollisionGroup(oldCollisionGroup)

	if replicator then
		sound.Play("star_trek.tng_replicator", ent:GetPos(), 10, 100, 0.5)
		ent:EmitSound("star_trek.tng_replicator", 10, 100, 0.5)
	else
		if remat then
			sound.Play("star_trek.voy_beam_down", ent:GetPos(), 10, 100, 0.5)
			ent:EmitSound("star_trek.voy_beam_down", 10, 100, 0.5)
		else
			sound.Play("star_trek.voy_beam_up"  , ent:GetPos(), 10, 100, 0.5)
			ent:EmitSound("star_trek.voy_beam_up", 10, 100, 0.5)
		end
	end

	timer.Simple(0.5, function()
		net.Start("Star_Trek.Transporter.TriggerEffect")
			net.WriteEntity(ent)
			net.WriteBool(remat)
			net.WriteBool(replicator)
			net.WriteVector(targetPos)
		net.Broadcast()
	end)
end

-- Beaming a given object from point a to b.
--
-- @param Entity ent
-- @param Vector targetPos
-- @param? Entity sourcePad
-- @param? Entity targetPad
-- @param? Boolean toBuffer
-- @param? Boolean replicator
function Star_Trek.Transporter:BeamObject(ent, targetPos, sourcePad, targetPad, toBuffer, replicator)
	local transportData = {
		Object = ent,
		TargetPos = targetPos or ent:GetPos(),
		StateTime = CurTime(),
		State = 1,
		SourcePad = sourcePad,
		TargetPad = targetPad,
		ToBuffer = toBuffer,
		Replicator = replicator,
	}

	for _, activeTransportData in pairs(self.ActiveTransports) do
		if activeTransportData.Object == ent then return end
	end

	if IsValid(sourcePad) then
		sourcePad:SetSkin(1)
	end
	if ent.BufferData then
		transportData = ent.BufferData
		ent.BufferData = nil

		transportData.TargetPos = targetPos or ent:GetPos()
		transportData.TargetPad = targetPad
		transportData.ToBuffer = false
	else
		self:TriggerEffect(transportData, ent)
		self:BroadcastEffect(ent, false, replicator, Star_Trek.Transporter.Buffer.Pos)
	end

	table.insert(self.ActiveTransports, transportData)
end

hook.Add("Think", "Star_Trek.Tranporter.Think", function()
	local toBeRemoved = {}
	for _, transportData in pairs(Star_Trek.Transporter.ActiveTransports) do
		local curTime = CurTime()

		local stateTime = transportData.StateTime
		local state = transportData.State
		local ent = transportData.Object

		if IsValid(ent) then
			if state == 1 and (stateTime + 3) < curTime then
				transportData.State = 2

				ent:SetPos(Star_Trek.Transporter.Buffer.Pos)

				-- Object is now dematerialized and moved to the buffer!
				Star_Trek.Transporter:TriggerEffect(transportData, ent)

				transportData.StateTime = curTime

				if IsValid(transportData.SourcePad) then
					transportData.SourcePad:SetSkin(0)
				end

				if transportData.Replicator then
					table.insert(toBeRemoved, transportData)
				end

				if transportData.ToBuffer then
					transportData.Object.BufferData = transportData

					table.insert(toBeRemoved, transportData)
				end
			elseif state == 2 and (stateTime + 4) < curTime then
				transportData.State = 3

				-- Object will now be removed from the buffer.
				Star_Trek.Transporter:TriggerEffect(transportData, ent)

				Star_Trek.Transporter:BroadcastEffect(ent, true, transportData.Replicator, Star_Trek.Transporter.Buffer.Pos)

				transportData.StateTime = curTime

				if IsValid(transportData.TargetPad) then
					transportData.TargetPad:SetSkin(1)
				end
			elseif state == 3 and (stateTime + 3) < curTime then
				transportData.State = 4

				-- Object is now visible again.
				Star_Trek.Transporter:TriggerEffect(transportData, ent)

				if IsValid(transportData.TargetPad) then
					transportData.TargetPad:SetSkin(0)
				end

				table.insert(toBeRemoved, transportData)
			end
		else
			table.insert(toBeRemoved, transportData)
		end
	end

	for _, transportData in pairs(toBeRemoved) do
		table.RemoveByValue(Star_Trek.Transporter.ActiveTransports, transportData)
	end
end)

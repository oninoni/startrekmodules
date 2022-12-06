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
--        Transporter | Server       --
---------------------------------------

util.AddNetworkString("Star_Trek.Transporter.TransportObject")
function Star_Trek.Transporter:TransportObject(cycleType, ent, targetPos, skipDemat, skipRemat, callback)
	hook.Run("Star_Trek.Transporter.PreTransportObject", cycleType, ent, targetPos, skipDemat, skipRemat, callback)

	if not IsEntity(ent) or not IsValid(ent) then
		return false, "Invalid Object"
	end

	local moveType = ent:GetMoveType()
	if moveType == MOVETYPE_NOCLIP then
		return false, "Object is untouchable."
	end

	local bufferPos = self:GetBufferPos()
	if not isvector(targetPos) then
		targetPos = bufferPos
		skipRemat = true
	end

	local success, transporterCycle = self:CreateCycle(cycleType, ent, targetPos, bufferPos, skipDemat, skipRemat)
	if not success then
		return false, transporterCycle
	end

	transporterCycle.Callback = callback
	if isfunction(callback) then
		callback(transporterCycle)
	end

	-- Offset to prevent stucking in floor
	local lowerBounds = ent:GetCollisionBounds()
	transporterCycle.ZOffset = -lowerBounds.Z + 2 -- TODO: Check lower value

	net.Start("Star_Trek.Transporter.TransportObject")
		net.WriteString(cycleType)
		net.WriteEntity(ent)
		net.WriteVector(targetPos)
		net.WriteVector(bufferPos)
		net.WriteBool(skipDemat)
	net.Broadcast()

	return true, transporterCycle
end

function Star_Trek.Transporter:EndTransporterCycle(transporterCycle)
	if not istable(transporterCycle) then
		return false, "No Transporter Cycle given!"
	end

	transporterCycle:End()

	net.Start("Star_Trek.Transporter.End")
		net.WriteEntity(transporterCycle.Entity)
		net.WriteInt(transporterCycle.State, 32)
	net.Broadcast()

	hook.Run("Star_Trek.Transporter.EndTransporterCycle", transporterCycle)

	return true
end

util.AddNetworkString("Star_Trek.Transporter.ApplyState")
util.AddNetworkString("Star_Trek.Transporter.End")

hook.Add("Think", "Star_Trek.Transporter.Think", function()
	local toBeRemoved = {}
	for _, transporterCycle in pairs(Star_Trek.Transporter.ActiveCycles) do
		local ent = transporterCycle.Entity
		if not IsValid(ent) then
			table.insert(toBeRemoved, transporterCycle)
			continue
		end

		local stateData = transporterCycle:GetStateData()
		if not stateData then continue end

		if CurTime() > transporterCycle.StateTime + stateData.Duration then
			local newState = transporterCycle.State + 1

			local success = transporterCycle:ApplyState(newState)
			if not success then
				Star_Trek.Transporter:EndTransporterCycle(transporterCycle)

				table.insert(toBeRemoved, transporterCycle)
			end

			local callback = transporterCycle.Callback
			if isfunction(callback) then
				callback(transporterCycle)
			end

			net.Start("Star_Trek.Transporter.ApplyState")
				net.WriteEntity(ent)
				net.WriteInt(newState, 8)
			net.Broadcast()
		end
	end

	for _, transporterCycle in pairs(toBeRemoved) do
		table.RemoveByValue(Star_Trek.Transporter.ActiveCycles, transporterCycle)
	end
end)

-- TODO
function Star_Trek.Transporter:GetBufferPos()
	return Star_Trek.Transporter.Buffer.Pos
end

-- Load Objects in Buffer to the client.
hook.Add("SetupPlayerVisibility", "Star_Trek.Transporter.PVS", function(ply, viewEntity)
	local bufferPos = Star_Trek.Transporter:GetBufferPos()
	if isvector(bufferPos) then
		AddOriginToPVS(bufferPos)
	end
end)

-- Prevent Item Pickup
hook.Add("PlayerCanPickupItem", "Star_Trek.Transporter.PreventPickup", function(ply, ent)
	local transporterCycle = Star_Trek.Transporter.ActiveCycles[ent]
	if istable(transporterCycle) then
		return false
	end
end)

-- Prevent Weapon Pickup
hook.Add("PlayerCanPickupWeapon", "Star_Trek.Transporter.PreventPickup", function(ply, ent)
	local transporterCycle = Star_Trek.Transporter.ActiveCycles[ent]
	if istable(transporterCycle) then
		return false
	end
end)

function Star_Trek.Transporter:CleanUp(ent, forceRemat)
	local transporterCycle = Star_Trek.Transporter.ActiveCycles[ent]
	if istable(transporterCycle) then
		Star_Trek.Transporter:EndTransporterCycle(transporterCycle)
		Star_Trek.Transporter.ActiveCycles[ent] = nil
	end

	if istable(Star_Trek.Transporter.Buffer)
	and istable(Star_Trek.Transporter.Buffer.Entities)
	and table.HasValue(Star_Trek.Transporter.Buffer.Entities, ent) then
		table.RemoveByValue(Star_Trek.Transporter.Buffer.Entities, ent)
		ent.BufferQuality = nil

		if forceRemat then
			Star_Trek.Transporter:TransportObject("base", ent, ent:GetPos(), true, false)
		end
	end
end

hook.Add("PlayerDeath", "Star_Trek.Transporter.BufferReset", function(ply)
	Star_Trek.Transporter:CleanUp(ply, true)
end)

hook.Add("PlayerSpawn", "Star_Trek.Transporter.BufferReset", function(ply)
	Star_Trek.Transporter:CleanUp(ply)
end)

hook.Add("PlayerDisconnected", "Star_Trek.Transporter.DisconnectReset", function(ply)
	Star_Trek.Transporter:CleanUp(ply)
end)

hook.Add("EntityRemoved", "Star_Trek.Transporter.RemoveReset", function(ent)
	Star_Trek.Transporter:CleanUp(ent)
end)

hook.Add("Star_Trek.Transporter.DetectInterference", "Star_Trek.Transporter.CheckShielded", function(sourcePattern, targetPattern)
	targetPos = targetPattern.Pos
	sourcePos = sourcePattern.Ent:GetPos()
	sourceSuccess, sourceDeck, sourceSecId = Star_Trek.Sections:DetermineSection(sourcePos)
	targetSuccess, targetDeck, targetSecId = Star_Trek.Sections:DetermineSection(targetPos)
	targetSectionSuccess, targetSection = Star_Trek.Sections:GetSection(targetDeck, targetSecId)
	sourceSectionSuccess, sourceSection = Star_Trek.Sections:GetSection(sourceDeck, sourceSecId)

	if not sourceSuccess and targetSuccess and targetSectionSuccess and sourceSectionSuccess then return false end

	targetFields = targetSection.ForceFields
	sourceFields = sourceSection.ForceFields
	fieldEnts = ents.FindByClass("force_field")
	numTargetFields = -1
	numSourceFields = -1

	--There are no fields if they are in an area without a section or something idk
	if sourceFields ~= nil then
		numSourceFields = #sourceFields
	end
	if targetFields ~= nil then
		numTargetFields = #targetFields
	end

	numActiveTarget = 0
	numActiveSource = 0

	for _, active in pairs(fieldEnts) do
		if numSourceFields ~= -1 then
			for _, sourceField in pairs(sourceFields) do
				if active:GetPos() == sourceField.Pos then
					numActiveSource = numActiveSource + 1
				end
			end
		end
		if numTargetFields ~= -1 then
			for _, targetField in pairs(targetFields) do
				if active:GetPos() == targetField.Pos then
					numActiveTarget = numActiveTarget + 1
				end
			end
		end
	end
	if numActiveTarget == numTargetFields then
		return true, "target"
	elseif numActiveSource == numSourceFields then
		return true, "source"
	else
		return false
	end
end)

timer.Create("Star_Trek.Transporter.BufferThink", 1, 0, function()
	local removeFromBuffer = {}

	for _, ent in pairs(Star_Trek.Transporter.Buffer.Entities) do
		if not isnumber(ent.BufferQuality) or ent.BufferQuality <= 0 then
			table.insert(removeFromBuffer, ent)

			if ent:IsPlayer() then
				ent:Kill()
			else
				SafeRemoveEntity(ent)
			end

			continue
		end

		ent.BufferQuality = ent.BufferQuality - 1

		if ent.BufferQuality < 100 then
			local maxHealth = ent:GetMaxHealth()
			if maxHealth > 0 then
				local health = math.min(ent:Health(), maxHealth * (ent.BufferQuality / 100))
				ent:SetHealth(health)
			end
		end
	end

	for _, ent in pairs(removeFromBuffer) do
		table.RemoveByValue(Star_Trek.Transporter.Buffer.Entities, ent)
		ent.BufferQuality = nil
	end

	if #removeFromBuffer > 0 then
		for _, interfaceData in pairs(Star_Trek.LCARS.ActiveInterfaces) do
			if isstring(interfaceData.CycleClass) then
				hook.Run("Star_Trek.Transporter.UpdateBuffer", interfaceData.Ent)
			end
		end
	end
end)
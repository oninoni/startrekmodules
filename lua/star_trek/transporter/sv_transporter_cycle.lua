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
--        Transporter | Server       --
---------------------------------------

util.AddNetworkString("Star_Trek.Transporter.TransportObject")
function Star_Trek.Transporter:TransportObject(cycleType, ent, targetPos, skipDemat, skipRemat, callback)
	local success, transporterCycle = self:CreateCycle(cycleType, ent, targetPos, skipDemat, skipRemat)
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
		net.WriteBool(skipDemat)
	net.Broadcast()

	return true, transporterCycle
end

function TestTransporter()
	local ent = player.GetHumans()[1]:GetEyeTrace().Entity
	print(Star_Trek.Transporter:TransportObject("federation", ent, ent:GetPos() + Vector(16, 0, 0)))
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
				transporterCycle:End()

				net.Start("Star_Trek.Transporter.End")
					net.WriteEntity(ent)
					net.WriteInt(transporterCycle.State, 32)
				net.Broadcast()

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

hook.Add("SetupPlayerVisibility", "Star_Trek.Transporter.PVS", function(ply, viewEntity)
	local transporterCycle = Star_Trek.Transporter.ActiveCycles[ply]
	if not istable(transporterCycle) then
		return
	end

	if istable(Star_Trek.Transporter.Buffer) then
		AddOriginToPVS(Star_Trek.Transporter.Buffer.Pos)
	end
end)
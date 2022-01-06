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
--        Transporter | Client       --
---------------------------------------

net.Receive("Star_Trek.Transporter.TransportObject", function()
	local cycleType = net.ReadString()
	local ent = net.ReadEntity()
	local targetPos = net.ReadVector()
	local skipDemat = net.ReadBool()

	local success, transporterCycle = Star_Trek.Transporter:CreateCycle(cycleType, ent, targetPos, skipDemat)
	if not success then
		print(transporterCycle)
	end
end)

net.Receive("Star_Trek.Transporter.ApplyState", function()
	local ent = net.ReadEntity()
	local newState = net.ReadInt(8)

	local transporterCycle = Star_Trek.Transporter.ActiveCycles[ent]
	if not istable(transporterCycle) then
		return
	end

	transporterCycle:ApplyState(newState)
end)

net.Receive("Star_Trek.Transporter.End", function()
	local ent = net.ReadEntity()

	local transporterCycle = Star_Trek.Transporter.ActiveCycles[ent]
	if not istable(transporterCycle) then
		return
	end
	
	transporterCycle:End()
	
	Star_Trek.Transporter.ActiveCycles[ent] = nil
end)

hook.Add("PostDrawTranslucentRenderables", "Star_Trek.Transporter.RenderCycle", function()
	local toBeRemoved = {}
	for _, transporterCycle in pairs(Star_Trek.Transporter.ActiveCycles) do
		local ent = transporterCycle.Entity
		if not IsValid(ent) then
			table.insert(toBeRemoved, transporterCycle)
			continue
		end

		transporterCycle:Render()
	end

	for _, transporterCycle in pairs(toBeRemoved) do
		table.RemoveByValue(Star_Trek.Transporter.ActiveCycles, transporterCycle)
	end
end)

hook.Add("RenderScreenspaceEffects", "Star_Trek.Transporter.LocalCycle", function()
	local localCycle = Star_Trek.Transporter.LocalCycle
	if istable(localCycle) then
		localCycle:RenderScreenspaceEffect()
	end
end)
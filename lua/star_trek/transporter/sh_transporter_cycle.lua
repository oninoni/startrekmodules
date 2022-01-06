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
--        Transporter | Shared       --
---------------------------------------

Star_Trek.Transporter.ActiveCycles = Star_Trek.Transporter.ActiveCycles or {}

function Star_Trek.Transporter:CreateCycle(cycleType, ent, targetPos, skipDemat, skipRemat)
	if not IsValid(ent) then
		return false, "Invalid Entity for Transport"
	end

	if self.ActiveCycles[ent] then
		return false, "Object already in Transport"
	end
	
	local transporterCycle = {
		CycleType = cycleType,
		Entity = ent,
		TargetPos = targetPos,

		SkipDemat = skipDemat,
		SkipRemat = skipRemat,
	}

	local cycleFunctions = self.Cycles[cycleType]
	if not istable(cycleFunctions) then
		return false, "Invalid Transporter Cycle Type"
	end
	setmetatable(transporterCycle, {__index = cycleFunctions})

	transporterCycle:Initialize()
	transporterCycle:ApplyState(self.State)

	self.ActiveCycles[ent] = transporterCycle
	ent.TransporterCycle = transporterCycle

	return true, transporterCycle
end
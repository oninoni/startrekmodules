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
--        Transporter | Shared       --
---------------------------------------

Star_Trek.Transporter.ActiveCycles = Star_Trek.Transporter.ActiveCycles or {}

function Star_Trek.Transporter:CreateCycle(cycleType, ent, targetPos, bufferPos, skipDemat, skipRemat)
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
		BufferPos = bufferPos,

		SkipDemat = skipDemat,
		SkipRemat = skipRemat,
	}

	local cycleFunctions = self.Cycles[cycleType]
	if not istable(cycleFunctions) then
		return false, "Invalid Transporter Cycle Type"
	end
	setmetatable(transporterCycle, {__index = cycleFunctions})

	transporterCycle:Initialize()
	transporterCycle:ApplyState(transporterCycle.State)

	self.ActiveCycles[ent] = transporterCycle

	return true, transporterCycle
end
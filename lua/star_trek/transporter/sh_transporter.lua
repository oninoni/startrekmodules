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

Star_Trek.Transporter.ActiveTransporterCycles = Star_Trek.Transporter.ActiveTransporterCycles or {}

function Star_Trek.Transporter:CreateTransporterCycle(type, ent, startState, ...)
	local transporterCycle = {
		Type = type,
		
		Entity = ent,
		State = startState or 1,
	}

	local cycleFunctions = self.Cycles[type]
	if not istable(cycleFunctions) then
		return false, "Invalid Transporter Cycle Type"
	end
	setmetatable(transporterCycle, {__index = cycleFunctions})

	transporterCycle:Initialize(...)

	self.ActiveTransporterCycles[ent] = transporterCycle
	ent.TransporterCycle = transporterCycle

	return true
end
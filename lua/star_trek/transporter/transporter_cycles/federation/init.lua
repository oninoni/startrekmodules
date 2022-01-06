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
--     Federation Cycle | Server     --
---------------------------------------

if not istable(CYCLE) then Star_Trek:LoadAllModules() return end
local SELF = CYCLE

-- Initializes the transporter cycle.
--
-- @param Entity ent
function SELF:Initialize()
	SELF.Base.Initialize(self)
end

-- Aborts the transporter cycle and brings the entity back to its normal state.
-- This can cause a player to be stuck somewhere he does not want to be and should only be used internally.
function SELF:Abort()
	SELF.Base.Abort(self)
end

-- Applies the current state to the transporter cycle.
--
-- @param Number state
function SELF:ApplyState(state)
	local success = SELF.Base.ApplyState(self, state)
	if not success then return false end

	return true
end
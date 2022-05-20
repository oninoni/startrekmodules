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

-- Applies the current state to the transporter cycle.
--
-- @param Number state
-- @param Boolean onlyRestore
function SELF:ApplyState(state, onlyRestore)
	local success = SELF.Base.ApplyState(self, state, onlyRestore)
	if not success then return false end

	return true
end
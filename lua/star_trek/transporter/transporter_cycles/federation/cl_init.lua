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
--     Federation Cycle | Client     --
---------------------------------------

if not istable(CYCLE) then Star_Trek:LoadAllModules() return end
local SELF = CYCLE

-- Initialises the transporter cycle.
--
-- @param Entity ent
function SELF:Initialise()
	SELF.Base.Initialize(self)
end

-- Applies the current state to the transporter cycle.
--
-- @param Number state
function SELF:ApplyState(state)
	SELF.Base.ApplyState(self, state)
end

-- Renders the effects of the transporter cycle.
function SELF:Render()
	SELF.Base.Render(self)
end
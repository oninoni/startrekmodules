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
--    Force Field Entity | Client    --
---------------------------------------

if not istable(ENT) then Star_Trek:LoadAllModules() return end

include("shared.lua")

function ENT:OnRemove()
	if self.LoopSound then
		self.LoopSound:Stop()
		self.LoopSound = nil
	end
end
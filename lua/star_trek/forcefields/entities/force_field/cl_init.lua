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
--    Force Field Entity | Client    --
---------------------------------------

include("shared.lua")

function ENT:OnRemove()
	if self.LoopSound then
		self.LoopSound:Stop()
		self.LoopSound = nil
	end
end
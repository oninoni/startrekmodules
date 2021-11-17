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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--            World Entity           --
--       Base Dynamic | Shared       --
---------------------------------------

ENT.BaseClass = "base"

function ENT:Think(deltaT)
	self.Pos = self.Pos + (self.Vel * deltaT)
	self.Ang = self.Ang + (self.AngVel * deltaT)
end
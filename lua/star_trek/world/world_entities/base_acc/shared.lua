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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--            World Entity           --
--     Base Acceleration | Shared    --
---------------------------------------

if not istable(ENT) then Star_Trek:LoadAllModules() return end
local SELF = ENT

SELF.BaseClass = "base_vel"

function SELF:Think(deltaT)
	self.Vel = self.Vel + (self.Acc * deltaT)
	self.AngVel = self.AngVel + (self.AngAcc * deltaT)

	self.Pos = self.Pos + (self.Vel * deltaT)
	self.Ang = self.Ang + (self.AngVel * deltaT)
end
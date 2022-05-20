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
--       Base Velocity | Server      --
---------------------------------------

if not istable(ENT) then Star_Trek:LoadAllModules() return end
local SELF = ENT

function SELF:WriteDynData()
	net.WriteWorldVector(self.Pos)
	net.WriteAngle(self.Ang)
end

function SELF:WriteData()
	net.WriteTable(self.Models)

	net.WriteVector(self.Vel)
	net.WriteAngle(self.AngVel)

	self:WriteDynData()
end

function SELF:Init(pos, ang, models, vel, angVel)
	SELF.Base.Init(self, pos, ang, models)

	self.Vel = vel or Vector()
	self.AngVel = angVel or Angle()
end
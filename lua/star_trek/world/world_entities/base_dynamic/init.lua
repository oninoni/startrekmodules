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
--       Base Dynamic | Server       --
---------------------------------------

function ENT:WriteDynData()
	net.WriteWorldVector(self.Pos)
	net.WriteAngle(self.Ang)
end

function ENT:WriteData()
	net.WriteTable(self.Models)

	net.WriteVector(self.Vel)
	net.WriteAngle(self.AngVel)

	self:WriteDynData()
end

function ENT:Init(pos, ang, models, vel, angVel)
	self.Pos = pos
	self.Ang = ang

	self.Models = models

	self.Vel = vel
	self.AngVel = angVel
end
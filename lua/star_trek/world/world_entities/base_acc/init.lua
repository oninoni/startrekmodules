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
--     Base Acceleration | Server    --
---------------------------------------

if not istable(ENT) then Star_Trek:LoadAllModules() return end
local SELF = ENT

function SELF:WriteData()
	net.WriteString(self.Model)
	net.WriteFloat(self.Scale)

	net.WriteVector(self.Acc)
	net.WriteAngle(self.AngAcc)
end

function SELF:WriteDynData()
	net.WriteWorldVector(self.Pos)
	net.WriteAngle(self.Ang)

	net.WriteFloat(self.Vel[1])
	net.WriteFloat(self.Vel[2])
	net.WriteFloat(self.Vel[3])

	net.WriteAngle(self.AngVel)
end

function SELF:Init(pos, ang, model, scale, vel, angVel, acc, angAcc)
	SELF.Base.Init(self, pos, ang, model, scale, vel, angVel)

	self.Acc = acc or Vector()
	self.AngAcc = angAcc or Angle()
end

function SELF:SetAcceleration(acc)
	self.Acc = acc

	self.Updated = true
end

function SELF:SetAngularAcceleration(angAcc)
	self.AngAcc = angAcc

	self.Updated = true
end
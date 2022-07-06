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
--       Base Velocity | Server      --
---------------------------------------

if not istable(ENT) then Star_Trek:LoadAllModules() return end
local SELF = ENT

function SELF:WriteData()
	net.WriteString(self.Model)
	net.WriteFloat(self.Scale)

	net.WriteFloat(self.Vel[1])
	net.WriteFloat(self.Vel[2])
	net.WriteFloat(self.Vel[3])

	net.WriteAngle(self.AngVel)
end

function SELF:WriteDynData()
	net.WriteWorldVector(self.Pos)
	net.WriteAngle(self.Ang)
end

function SELF:Init(pos, ang, model, scale, vel, angVel)
	SELF.Base.Init(self, pos, ang, model, scale)

	self.Vel = vel or Vector()
	self.AngVel = angVel or Angle()
end

function SELF:SetVelocity(vel)
	self.Vel = vel

	self.Updated = true
end

function SELF:SetAngularVelocity(angVel)
	self.AngVel = angVel

	self.Updated = true
end
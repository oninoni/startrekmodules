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
--           Base | Server           --
---------------------------------------

function ENT:WriteDynData()
end

function ENT:WriteData()
	net.WriteWorldVector(self.Pos)
	net.WriteAngle(self.Ang)

	net.WriteTable(self.Models)

	self:WriteDynData()
end

function ENT:Init(pos, ang, models)
	self.Pos = pos
	self.Ang = ang

	self.Models = models
end

function ENT:Terminate()
end
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
--       Base Dynamic | Client       --
---------------------------------------

function ENT:ReadDynData()
	self.Pos = net.ReadWorldVector()
	self.Ang = net.ReadAngle()
end

function ENT:ReadData()
	self.Models = net.ReadTable()

	self.Vel 	= net.ReadVector() -- TODO: Maybe need World Vector?
	self.AngVel = net.ReadAngle()

	self:ReadDynData()
end

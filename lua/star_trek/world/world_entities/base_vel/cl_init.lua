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
--       Base Velocity | Client      --
---------------------------------------

if not istable(ENT) then Star_Trek:LoadAllModules() return end
local SELF = ENT

function SELF:ReadDynData()
	self.Pos = net.ReadWorldVector()
	self.Ang = net.ReadAngle()
end

function SELF:ReadData()
	self.Models = net.ReadTable()

	self.Vel 	= net.ReadVector() -- TODO: Maybe need World Vector?
	self.AngVel = net.ReadAngle()

	self:ReadDynData()
end

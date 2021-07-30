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

function ENT:SetDynData(data)
	self.Pos = data.Pos
	self.Ang = data.Ang
end

function ENT:GetDynData()
	local data = {}

	data.Pos = self.Pos
	data.Ang = self.Ang

	return data
end

function ENT:SetData(data)
	self:SetDynData(data)

	self.Vel 	= data.Vel
	self.AngVel = data.AngVel

	self.Models = data.Models
end

function ENT:GetData()
	local data = self:GetDynData()

	data.Vel 	= self.Vel
	data.AngVel = self.AngVel

	data.Models = self.Models

	return data
end
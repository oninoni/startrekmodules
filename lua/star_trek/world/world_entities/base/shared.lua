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
--           Base | Shared           --
---------------------------------------

ENT.BaseClass = nil

function ENT:SetDynData(data)
end

function ENT:GetDynData()
	return {}
end

function ENT:SetData(data)
	self:SetDynData(data)

	self.Pos = data.Pos
	self.Ang = data.Ang

	self.Models = data.Models
end

function ENT:GetData()
	local data = self:GetData()

	data.Pos = self.Pos
	data.Ang = self.Ang

	data.Models = data.Models

	return data
end
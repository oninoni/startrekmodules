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
--           Base | Client           --
---------------------------------------

if not istable(ENT) then Star_Trek:LoadAllModules() return end
local SELF = ENT

function SELF:ReadData()
	self.Pos = net.ReadWorldVector()
	self.Ang = net.ReadAngle()

	self.Model = net.ReadString()
	self.Scale = net.ReadFloat()
end

function SELF:ReadDynData()
end

function SELF:Init()
	self:ReadData()
	self:ReadDynData()

	local ent = ClientsideModel(self.Model, RENDERGROUP_BOTH)
	ent:SetModelScale(self.Scale or 1)
	ent:SetNoDraw(true)

	self.ClientEntity = ent
end

function SELF:Terminate()
	SafeRemoveEntity(self.ClientEntity)
end
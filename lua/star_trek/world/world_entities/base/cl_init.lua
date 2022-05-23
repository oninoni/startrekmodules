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
--           Base | Client           --
---------------------------------------

if not istable(ENT) then Star_Trek:LoadAllModules() return end
local SELF = ENT

function SELF:ReadDynData()
end

function SELF:ReadData()
	self.Pos = net.ReadWorldVector()
	self.Ang = net.ReadAngle()

	self.Models = net.ReadTable()

	self:ReadDynData()
end

function SELF:Init()
	self:ReadData()

	self.ClientEntities = {}
	for i, modelData in pairs(self.Models) do
		local ent = ClientsideModel(modelData.Model, RENDERGROUP_BOTH)

		ent.Scale = modelData.Scale or 1
		ent:SetModelScale(ent.Scale)

		ent:SetNoDraw(true)

		-- TODO: Add Support for Offset / Parenting (Parenting might be possible clientside improving performance?)

		self.ClientEntities[i] = ent
	end
end

function SELF:Terminate()
	for i, ent in pairs(self.ClientEntities) do
		SafeRemoveEntity(ent)
	end
end

function SELF:Draw(camPos, relPos, relAng)
	for _, ent in pairs(self.ClientEntities) do
		Star_Trek.World:DrawEntity(ent, camPos, relPos, relAng)
	end
end
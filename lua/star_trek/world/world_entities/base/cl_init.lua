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

function ENT:ReadDynData()
end

function ENT:ReadData()
	self.Pos = net.ReadWorldVector()
	self.Ang = net.ReadAngle()

	self.Models = net.ReadTable()

	self:ReadDynData()
end

function ENT:Init()
	self:ReadData()

	print("Initializing")

	self.ClientEntities = {}
	for i, modelData in pairs(self.Models) do
		print("MD", modelData)

		local ent = ClientsideModel(modelData.Model, RENDERGROUP_BOTH)

		ent:SetModelScale(modelData.Scale)
		ent.Scale = modelData.Scale

		ent:SetNoDraw(true)

		-- TODO: Add Support for Offset / Parenting (Parenting might be possible clientside improving performance?)

		self.ClientEntities[i] = ent
	end
end

function ENT:Terminate()
	for i, ent in pairs(self.ClientEntities) do
		SafeRemoveEntity(ent)
	end
end

function ENT:Draw(camPos, relPos, relAng)
	for _, ent in pairs(self.ClientEntities) do
		Star_Trek.World:DrawEntity(ent, camPos, relPos, relAng)
	end
end
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
--           Base | Server           --
---------------------------------------

if not istable(ENT) then Star_Trek:LoadAllModules() return end
local SELF = ENT

function SELF:WriteData()
	net.WriteWorldVector(self.Pos)
	net.WriteAngle(self.Ang)

	net.WriteString(self.Model)
	net.WriteFloat(self.Scale)
end

function SELF:WriteDynData()
end

function SELF:Init(pos, ang, model, scale)
	self.Pos = pos or WorldVector()
	self.Ang = ang or Angle()

	self.Scale = scale or Star_Trek.World.Skybox_Scale
	self.Model = model or "models/hunter/blocks/cube4x4x4.mdl"
end

function SELF:Terminate()
end

function SELF:Update()
	Star_Trek.World:NetworkUpdate(self)

	self.Updated = nil
end

function SELF:SetPosition(pos)
	self.Pos = pos

	self.Updated = true
end

function SELF:SetAngle(ang)
	self.Ang = ang

	self.Updated = true
end
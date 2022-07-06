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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--   Transporter Cycle | Collision   --
---------------------------------------

if not istable(CYCLE) then Star_Trek:LoadAllModules() return end
local SELF = CYCLE

-- Reset the collision group of a given entity.
--
-- @param Entity ent
function SELF:ResetCollisionGroup(ent)
	local resetCollisionGroup = ent.TransporterResetCollisionGroup
	if resetCollisionGroup then
		ent:SetCollisionGroup(resetCollisionGroup)
		ent.TransporterResetCollisionGroup = nil
	end
end

-- Set the collision group of a given entity.
--
-- @param Entity ent
-- @param Number collisionGroup
function SELF:ApplyCollisionGroup(ent, collisionGroup)
	self:ResetCollisionGroup(ent)

	ent.TransporterResetCollisionGroup = ent:GetCollisionGroup()
	ent:SetCollisionGroup(collisionGroup)
end

-- Reset the collision group of the main entity and it's children.
function SELF:ResetCollisionGroups()
	local ent = self.Entity

	self:ResetCollisionGroup(ent)

	for _, child in pairs(ent:GetChildren()) do
		self:ResetCollisionGroup(child)
	end
end

-- Set the collision group of the main entity and it's children.
--
-- @param Number collisionGroup
function SELF:ApplyCollisionGroups(collisionGroup)
	local ent = self.Entity

	self:ApplyCollisionGroup(ent, collisionGroup)

	for _, child in pairs(ent:GetChildren()) do
		self:ApplyCollisionGroup(child, collisionGroup)
	end
end
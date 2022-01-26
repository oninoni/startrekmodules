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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--   Transporter Cycle | Particles   --
---------------------------------------

if not istable(CYCLE) then Star_Trek:LoadAllModules() return end
local SELF = CYCLE

-- Reset the particle system of a given entity.
--
-- @param Entity ent
function SELF:ResetParticleSystem(ent)
	if IsValid(ent.TransporterParticleEffect) then
		ent.TransporterParticleEffect:StopEmission()
	end
end

-- Create the particle system of a given entity.
--
-- @param Entity ent
-- @param String particleName
-- @param Vector centerPos
function SELF:ApplyParticleSystem(ent, particleName, centerPos)
	self:ResetParticleSystem(ent)

	ent.TransporterParticleEffect = CreateParticleSystem(ent, particleName, PATTACH_ABSORIGIN_FOLLOW)
	ent.TransporterParticleEffect:SetControlPoint(1, centerPos)
end

-- Reset the particle system of the main entity and it's children.
function SELF:ResetParticleSystems()
	local ent = self.Entity

	self:ResetParticleSystem(ent)

	for _, child in pairs(ent:GetChildren()) do
		self:ResetParticleSystem(child)
	end
end

-- Create the particle system of the main entity and it's children.
--
-- @param String particleName
-- @param Vector centerPos
function SELF:ApplyParticleSystems(particleName, centerPos)
	local ent = self.Entity

	self:ApplyParticleSystem(ent, particleName, centerPos)

	for _, child in pairs(ent:GetChildren()) do
		self:ApplyParticleSystem(child, particleName, centerPos)
	end
end
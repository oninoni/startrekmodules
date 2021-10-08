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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--    Force Field Entity | Server    --
---------------------------------------

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Delay = 1
ENT.Damage = 5
ENT.Force = 1

function ENT:Initialize()
	self:SetPersistent(true)
	self:SetRenderMode(RENDERGROUP_BOTH)
	self:DrawShadow(false)

	self:PhysicsInit(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	self:EmitSound("star_trek.force_field_on")
	self.LoopId = self:StartLoopingSound("star_trek.force_field_loop")
end

function ENT:OnRemove()
	self:EmitSound("star_trek.force_field_off")
	self:StopLoopingSound(self.LoopId)
end

function ENT:TouchSound()
	if math.random() > 0.5 then
		self:EmitSound("star_trek.force_field_touch")
	else
		self:EmitSound("star_trek.force_field_touch2")
	end
end

function ENT:Touch(ent)
	if not ent.LastTouch or ent.LastTouch + self.Delay < CurTime() then
		ent.LastTouch = CurTime()

		local normal = ent:GetPos() - self:GetPos()
		normal:Normalize()

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			self:TouchSound()

			local dmg = DamageInfo()
			dmg:SetAttacker(self)
			dmg:SetInflictor(self)

			dmg:SetDamage(self.Damage)
			dmg:SetDamageType(DMG_SHOCK)
			dmg:SetDamageForce(normal * phys:GetMass() * self.Force)

			ent:TakeDamageInfo(dmg)
		end
	end
end

function ENT:OnTakeDamage(dmgInfo)
	self:TouchSound()

	return 0
end
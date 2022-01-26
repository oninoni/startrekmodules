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
--  Base Transporter Cycle | Server  --
---------------------------------------

if not istable(CYCLE) then Star_Trek:LoadAllModules() return end
local SELF = CYCLE

-- Initializes the transporter cycle.
--
-- @param Entity ent
function SELF:Initialize()
	self.State = 1

	if self.SkipDemat then
		self.State = self.SkipDematState
	end
end

function SELF:ResetCollisionGroup()
	local ent = self.Entity

	local defaultCollisionGroup = ent.TransporterDefaultCollisionGroup
	if defaultCollisionGroup == nil then
		defaultCollisionGroup = COLLISION_GROUP_NONE
	end

	ent:SetCollisionGroup(defaultCollisionGroup)
end

function SELF:ApplyDisableMovement(disableMovement)
	local ent = self.Entity

	if ent:IsPlayer() then
		ent:Freeze(disableMovement)
	elseif ent:IsNPC() then
		if disableMovement then
			ent:MoveStop()
		else
			ent:MoveStart()
		end
	elseif ent:IsNextBot() then
		return -- TODO
	else
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(not disableMovement)
		end
	end
end

function SELF:End()
	local stateData = self:GetStateData()
	print(self.State, stateData)
	if istable(stateData) then return end

	local ent = self.Entity
	if IsValid(ent) then
		self:ResetRenderMode()
		self:ResetCollisionGroup()

		ent:DrawShadow(true)
		self:ApplyDisableMovement(false)

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end
	end
end

-- Aborts the transporter cycle and brings the entity back to its normal state.
-- This will dump the player into the transporter buffer!
function SELF:Abort()
	self:End()

	local ent = self.Entity

	ent:SetPos(self.BufferPos)
end

-- Applies the current state to the transporter cycle.
--
-- @param Number state
function SELF:ApplyState(state)
	self.State = state
	self.StateTime = CurTime()

	local stateData = self:GetStateData()
	if not istable(stateData) then return false end

	local ent = self.Entity

	local renderMode = stateData.RenderMode
	if renderMode ~= nil then
		if renderMode == false then
			self:ResetRenderMode()
			ent.TransporterDefaultRenderMode = nil
		else
			ent.TransporterDefaultRenderMode = ent.TransporterDefaultRenderMode or ent:GetRenderMode()
			ent:SetRenderMode(renderMode)
		end
	end

	local collisionGroup = stateData.CollisionGroup
	if collisionGroup ~= nil then
		if collisionGroup == false then
			self:ResetCollisionGroup()
			ent.TransporterDefaultCollisionGroup = nil
		else
			ent.TransporterDefaultCollisionGroup = ent.TransporterDefaultCollisionGroup or ent:GetCollisionGroup()
			ent:SetCollisionGroup(collisionGroup)
		end
	end

	local disableMovement = stateData.DisableMovement
	if disableMovement ~= nil then
		self:ApplyDisableMovement(disableMovement)
	end

	local shadow = stateData.Shadow
	if shadow ~= nil then
		ent:DrawShadow(shadow)
	end

	if stateData.TPToBuffer then
		ent:SetPos(self.BufferPos)
	end

	if stateData.TPToTarget then
		local lowerBounds = ent:GetCollisionBounds()
		local zOffset = -lowerBounds.Z + 2 -- Offset to prevent stucking in floor

		ent:SetPos(self.TargetPos + Vector(0, 0, zOffset))
	end

	local soundName = stateData.SoundName
	if soundName then
		sound.Play(soundName, ent:GetPos(), 20, 100, 0.5)
	end

	if self.SkipRemat and state == self.SkipRematState then return false end

	return true
end
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

function SELF:ResetMoveType()
	local ent = self.Entity

	local defaultMoveType = ent.TransporterDefaultMoveType
	if defaultMoveType == nil then
		defaultMoveType = MOVETYPE_VPHYSICS
	end

	ent:SetMoveType(defaultMoveType)
end

function SELF:End()
	local ent = self.Entity
	
	self:ResetCollisionGroup()
	self:ResetMoveType()

	ent:DrawShadow(true)

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
end

-- Aborts the transporter cycle and brings the entity back to its normal state.
-- This will dump the player into the transporter buffer!
function SELF:Abort()
	self:End()
	
	local ent = self.Entity

	local bufferPos = Star_Trek.Transporter:GetBufferPos()
	ent:SetPos(bufferPos)
end

-- Applies the current state to the transporter cycle.
--
-- @param Number state
function SELF:ApplyState(state)
	self.State = state
	self.StateTime = CurTime()

	if self.SkipRemat and state == self.SkipRematState then return false end

	local stateData = self:GetStateData()
	if not istable(stateData) then return false end
	
	local ent = self.Entity

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
	
	local moveType = stateData.MoveType
	if moveType ~= nil then
		if moveType == false then
			self:ResetMoveType()
			ent.TransporterDefaultMoveType = nil
		else
			ent.TransporterDefaultMoveType = ent.TransporterDefaultMoveType or ent:GetMoveType()
			ent:SetMoveType(moveType)
		end
	end

	local shadow = stateData.Shadow
	if shadow ~= nil then
		ent:DrawShadow(shadow)
	end

	if stateData.TPToBuffer then
		local bufferPos = Star_Trek.Transporter:GetBufferPos()
		ent:SetPos(bufferPos)
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

	return true
end
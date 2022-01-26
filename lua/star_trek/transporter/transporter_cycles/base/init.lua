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

function SELF:End()
	local stateData = self:GetStateData()
	if istable(stateData) then return end

	local ent = self.Entity
	if IsValid(ent) then
		self:ResetCollisionGroups()
		self:ResetRenderModes()

		ent:DrawShadow(true)
		self:ApplyMovement(true)

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

	local collisionGroup = stateData.CollisionGroup
	if collisionGroup ~= nil then
		self:ApplyCollisionGroups(collisionGroup)
	end

	local renderMode = stateData.RenderMode
	if renderMode ~= nil then
		self:ApplyRenderModes(renderMode)
	end

	local enableMovement = stateData.EnableMovement
	if enableMovement ~= nil then
		self:ApplyMovement(enableMovement)
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
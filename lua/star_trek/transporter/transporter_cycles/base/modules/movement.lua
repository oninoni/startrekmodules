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
--    Transporter Cycle | Movement   --
---------------------------------------

if not istable(CYCLE) then Star_Trek:LoadAllModules() return end
local SELF = CYCLE

-- Applies the movement to the entity.
-- Parenting is not done since parented entities do not move.
--
-- @param Bool movementEnabled
function SELF:ApplyMovement(movementEnabled)
	local ent = self.Entity

	if ent:IsPlayer() then
		ent:Freeze(not movementEnabled)
	elseif ent:IsNPC() then
		if movementEnabled then
			ent:MoveStart()
		else
			ent:MoveStop()
		end
	elseif ent:IsNextBot() then
		return -- TODO
	else
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(movementEnabled)
		end

		local pCount = ent:GetPhysicsObjectCount()
		if pCount > 1 then
			for i = 1, pCount - 1 do
				local subPhys = ent:GetPhysicsObjectNum(i)
				subPhys:EnableMotion(movementEnabled)
			end
		end
	end
end
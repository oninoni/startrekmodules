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
--          Chairs | Server          --
---------------------------------------

-- Checks if entity is a chair.
--
-- @param Entity chair
-- @return Bool isChair
local function isStarTrekChair(ent)
	if IsValid(ent) and ent:GetClass() == "prop_vehicle_prisoner_pod" and Star_Trek.Chairs.ModelNames[ent:GetModel()] then
		return true
	end

	return false
end

-- Sets up one entity as a chair, if it is a chair.
--
-- @param Entity chair
local function setupChair(ent)
	if isStarTrekChair(ent) then
		ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
end
hook.Add("OnEntityCreated", "Star_Trek.ChairsOnEntityCreated", function(ent) timer.Simple(0, function() setupChair(ent) end) end)

-- Set up all chairs from the map with their collision group.
local function setupChairs()
	for _, ent in pairs(ents.FindByClass("prop_vehicle_prisoner_pod")) do
		setupChair(ent)
	end
end
hook.Add("InitPostEntity", "Star_Trek.ChairsInitPostEntity", setupChairs)
hook.Add("PostCleanupMap", "Star_Trek.ChairsPostCleanupMap", setupChairs)

-- Save View Angle when leaving a chair.
hook.Add("CanExitVehicle", "Star_Trek.CheckLeaveChair", function(chair, ply)
	if isStarTrekChair(chair) then
		ply.STPrevViewAngle = ply:EyeAngles()
		ply.STPrevViewAngle.r = 0
	end
end)

-- Set Position and View Angle after leaving a chair.
hook.Add("PlayerLeaveVehicle", "Star_Trek.LeaveChair", function(ply, chair)
	if not isStarTrekChair(chair) then
		return
	end

	ply:SetPos(chair:GetPos())
	if isangle(ply.STPrevViewAngle) then
		ply:SetEyeAngles(ply.STPrevViewAngle)
	end
end)

-- Enable crosshair in chair.
hook.Add("PlayerEnteredVehicle", "Star_Trek.EnterConsoleChair", function(ply, chair, role)
	if isStarTrekChair(chair) then
		ply:CrosshairEnable()
	end
end)
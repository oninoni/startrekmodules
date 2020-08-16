-- Set up all chairs from the map with their collision group.
-- TODO: Add Chair Models instead of Map ID Check
local function setupChairs()
    for _, ent in pairs(ents.FindByClass("prop_vehicle_prisoner_pod")) do
        if ent:MapCreationID() ~= -1 then
            ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
        end
    end
end
hook.Add("InitPostEntity", "LCARS.ChairsInitPostEntity", setupChairs)
hook.Add("PostCleanupMap", "LCARS.ChairsPostCleanupMap", setupChairs)

-- TODO: Add Entity Spawning aswell.

-- Save View Angle when leaving a chair.
-- TODO: Add Chair Models instead of Map ID Check
hook.Add("CanExitVehicle", "LCARS.CheckLeaveChair", function(chair, ply)
	if chair:GetClass() == "prop_vehicle_prisoner_pod" and chair:MapCreationID() ~= -1 then
		ply.LCARSPrevViewAngle = ply:EyeAngles()
	end
end)

-- Set Position and View Angle after leaving a chair.
-- TODO: Add Chair Models instead of Map ID Check
hook.Add("PlayerLeaveVehicle", "LCARS.LeaveChair", function(ply, chair)
	if chair:GetClass() == "prop_vehicle_prisoner_pod" and chair:MapCreationID() ~= -1 then
		ply:SetPos(chair:GetPos())
		ply:SetEyeAngles(ply.LCARSPrevViewAngle)
	end
end)

-- Enable crosshair in chair.
-- TODO: Add Chair Models instead of Map ID Check
hook.Add("PlayerEnteredVehicle", "LCARS.EnterConsoleChair", function(ply, chair, role)
	if chair:GetClass() == "prop_vehicle_prisoner_pod" and chair:MapCreationID() ~= -1 then
		ply:CrosshairEnable()
	end
end)
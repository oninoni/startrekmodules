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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--          Chairs | Server          --
---------------------------------------

-- Set up all chairs from the map with their collision group.
local function setupChairs()
    for _, ent in pairs(ents.FindByClass("prop_vehicle_prisoner_pod")) do
        if ent:MapCreationID() ~= -1 then
            ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
        end
    end
end
hook.Add("InitPostEntity", "Star_Trek.ChairsInitPostEntity", setupChairs)
hook.Add("PostCleanupMap", "Star_Trek.ChairsPostCleanupMap", setupChairs)

-- Save View Angle when leaving a chair.
hook.Add("CanExitVehicle", "Star_Trek.CheckLeaveChair", function(chair, ply)
	if chair:GetClass() == "prop_vehicle_prisoner_pod" and chair:MapCreationID() ~= -1 then
		ply.STPrevViewAngle = ply:EyeAngles()
	end
end)

-- Set Position and View Angle after leaving a chair.
hook.Add("PlayerLeaveVehicle", "Star_Trek.LeaveChair", function(ply, chair)
	if chair:GetClass() == "prop_vehicle_prisoner_pod" and chair:MapCreationID() ~= -1 then
		timer.Simple(0, function()
			ply:SetPos(chair:GetPos())
			ply:SetEyeAngles(ply.STPrevViewAngle)
		end)
	end
end)

-- Enable crosshair in chair.
hook.Add("PlayerEnteredVehicle", "Star_Trek.EnterConsoleChair", function(ply, chair, role)
	if chair:GetClass() == "prop_vehicle_prisoner_pod" and chair:MapCreationID() ~= -1 then
		ply:CrosshairEnable()
	end
end)
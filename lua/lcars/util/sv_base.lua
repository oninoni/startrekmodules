

-- Checks whether something is blocking the specified position within the radius.
-- 
-- @param Vector pos
-- @param? Number radius - defaults to 35 which is good for checking players positions.
function LCARS:IsEmptyPos(pos, lower, higher, radius)
	radius = radius or 35

    if pos.x < lower.x
    or pos.x > higher.x
    or pos.y < lower.y
    or pos.y > higher.y
    or pos.z < lower.z
    or pos.z > higher.z then
        return false
    end

	-- Check whether the position is inside something blocking in the map.
	local point = util.PointContents(pos + Vector(0, 0, 1))

	if point == CONTENTS_SOLID
		or point == CONTENTS_MOVEABLE
		or point == CONTENTS_LADDER
		or point == CONTENTS_PLAYERCLIP
		or point == CONTENTS_MONSTERCLIP
	then
		return false
	end

	local entities = ents.FindInSphere(pos, radius)

	-- The position will be considered empty if there are no entities inside the sphere.
	if #entities == 0 then
		return true
	end

	-- The position will be considered taken if there is a solid entity inside the sphere
	for k, entity in pairs(entities) do
		if entity:IsSolid() then
			return false
		end
	end

	return true
end

-- Returns pos if it is empty, if not, it tries to find a near
-- position that is empty and returns it as an alternative position.
--
-- @param Vector pos
-- @return Vector pos or Boolean false if no empty position was found.
function LCARS:FindEmptyPosWithin(pos, lower, higher)
	local x = pos.x
	local y = pos.y
	local z = pos.z
	local apos

	if self:IsEmptyPos(pos, lower, higher) then
		return pos
	end
	
	-- Look in steps of 8 for an empty position.
	-- Modify x and y coordinates in every possible combination
	-- until an empty position is found.
	for i = 8, 200, 8 do
		apos = Vector(x + i, y, z)
		if self:IsEmptyPos(apos, lower, higher) then
			return apos
		end

		apos = Vector(x - i, y, z)
		if self:IsEmptyPos(apos, lower, higher) then
			return apos
		end

		apos = Vector(x, y + i, z)
		if self:IsEmptyPos(apos, lower, higher) then
			return apos
		end

		apos = Vector(x, y - i, z)
		if self:IsEmptyPos(apos, lower, higher) then
			return apos
		end

		apos = Vector(x + i, y + i, z)
		if self:IsEmptyPos(apos, lower, higher) then
			return apos
		end

		apos = Vector(x - i, y - i, z)
		if self:IsEmptyPos(apos, lower, higher) then
			return apos
		end

		apos = Vector(x + i, y - i, z)
		if self:IsEmptyPos(apos, lower, higher) then
			return apos
		end

		apos = Vector(x - i, y + i, z)
		if self:IsEmptyPos(apos, lower, higher) then
			return apos
		end
	end

	return false
end

-- Keyvalues

-- Capture all Keyvalues so they can be read when needed.
hook.Add("EntityKeyValue", "LCARS.CaptureKeyValues", function(ent, key, value)
    ent.LCARSKeyData = ent.LCARSKeyData or {}

    if string.StartWith(key, "lcars") then
        ent.LCARSKeyData[key] = value

		hook.Run("LCARS.ChangedKeyValue", ent, key, value)
    end
end)

-- Capture Live Changes to lcars convars.
hook.Add("AcceptInput", "LCARS.CaptureKeyValuesLive", function(ent, input, activator, caller, value)
    if input ~= "AddOutput" then return end

    local valueSplit = string.Split(value, " ")
    local key = valueSplit[1]
    if string.StartWith(key, "lcars") then
    	ent.LCARSKeyData = ent.LCARSKeyData or {}

		local realValue = ""
		for i, splitString in pairs(valueSplit) do
			if i == 1 then continue end
			if i ~= #valueSplit then 
				realValue = realValue .. " "
			end
			realValue = realValue .. splitString
		end
        ent.LCARSKeyData[key] = realValue

		hook.Run("LCARS.ChangedKeyValue", ent, key, realValue)
    end
end)

-- Chairs

-- Set up all chairs from the map with their collision group.
local function setupChairs()
    for _, ent in pairs(ents.FindByClass("prop_vehicle_prisoner_pod")) do
        if ent:MapCreationID() ~= -1 then
            ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
        end
    end
end
hook.Add("InitPostEntity", "LCARS.ChairsInitPostEntity", setupChairs)
hook.Add("PostCleanupMap", "LCARS.ChairsPostCleanupMap", setupChairs)

-- Save View Angle when leaving a chair.
hook.Add("CanExitVehicle", "LCARS.CheckLeaveChair", function(chair, ply)
	if chair:GetClass() == "prop_vehicle_prisoner_pod" and chair:MapCreationID() ~= -1 then
		ply.LCARSPrevViewAngle = ply:EyeAngles()
	end
end)

-- Set Position and View Angle after leaving a chair.
hook.Add("PlayerLeaveVehicle", "LCARS.LeaveChair", function(ply, chair)
	if chair:GetClass() == "prop_vehicle_prisoner_pod" and chair:MapCreationID() ~= -1 then
		ply:SetPos(chair:GetPos())
		ply:SetEyeAngles(ply.LCARSPrevViewAngle)
	end
end)

hook.Add("PlayerEnteredVehicle", "LCARS.EnterConsoleChair", function(ply, chair, role)
	if chair:GetClass() == "prop_vehicle_prisoner_pod" and chair:MapCreationID() ~= -1 then
		ply:CrosshairEnable()
	end
end)
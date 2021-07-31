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
--       World Render | Client       --
---------------------------------------

-- Vector_Max in Skybox is  (2^17) 
-- @ x1024 (2^10) Scale -> Visually at 134217728 (2^27)
local VECTOR_MAX = 131071


-- Sky Cam is not Readable Clientside, which is absurd...
-- TODO: Maybe I can network it? Config for now.
local SKY_CAM_POS = Vector(-4032, 0, 12800)
local SKY_CAM_SCALE = Star_Trek.World.Skybox_Scale

-- Optimisation we pre-create the border Vectors.
local VEC_MAX_LIST = {
	Vector( VECTOR_MAX, 0, 0),
	Vector(-VECTOR_MAX, 0, 0),
	Vector(0,  VECTOR_MAX, 0),
	Vector(0, -VECTOR_MAX, 0),
	Vector(0, 0,  VECTOR_MAX),
	Vector(0, 0, -VECTOR_MAX),
}

-- TODO: Optimize using the fact, that the plane is axis aligned.
local function IntersectPlaneAxis(pos, dir, direction)
	local vec_max = VEC_MAX_LIST[direction]
	return util.IntersectRayWithPlane(pos, dir, vec_max, vec_max)
end

local function IntersectWithBorder(pos, dir)
	local direction = 1
	if dir[1] < 0 then
		direction = 2
	end

	local xHit = IntersectPlaneAxis(pos, dir, direction)
	if xHit and math.abs(xHit[2]) < VECTOR_MAX and math.abs(xHit[3]) < VECTOR_MAX then
		return xHit
	end

	direction = 3
	if dir[1] < 0 then
		direction = 4
	end

	local yHit = IntersectPlaneAxis(pos, dir, direction)
	if yHit and math.abs(yHit[1]) < VECTOR_MAX and math.abs(yHit[2]) < VECTOR_MAX then
		return yHit
	end

	direction = 5
	if dir[1] < 0 then
		direction = 6
	end

	local zHit = IntersectPlaneAxis(pos, dir, direction)
	if zHit and math.abs(zHit[1]) < VECTOR_MAX and math.abs(zHit[2]) < VECTOR_MAX then
		return zHit
	end

	return false
end

-- Draws an object relative to you.
--
-- @param ClientsideEntity ent
-- @param Vector camPos
-- @param Vector relPos
-- @param Vector relAng
function Star_Trek.World:DrawEntity(ent, camPos, relPos, relAng)
	local relWorldPos = SKY_CAM_POS + relPos

	-- Check if in within Vector_Max
	local maxValue = math.max(
		math.abs(relWorldPos[1]),
		math.abs(relWorldPos[2]),
		math.abs(relWorldPos[3])
	)

	if maxValue >= VECTOR_MAX then
		local entDir = relWorldPos - camPos
		local distance = entDir:Length()
		entDir:Normalize()

		relWorldPos = IntersectWithBorder(camPos, entDir)
		if not relWorldPos then return end
		local projectedDistance = camPos:Distance(relWorldPos)

		local factor = projectedDistance / distance
		ent:SetModelScale(ent.Scale * factor)

		firstTime = false
	else
		if ent:GetModelScale() ~= ent.Scale then
			ent:SetModelScale(ent.Scale)
		end
	end

	ent:SetPos(relWorldPos)
	ent:SetAngles(relAng)
	ent:DrawModel()
end

function Star_Trek.World:Draw()
	local shipPos, shipAng = Star_Trek.World:GetShipPos()
	if not shipPos then return end

	local eyePos = EyePos()
	cam.Start3D(eyePos, EyeAngles(), nil, nil, nil, nil, nil, 0.0005, 10000000)
		local camPos = SKY_CAM_POS + (eyePos * SKY_CAM_SCALE)

		for i, ent in pairs(self.Entities) do
			if i == 1 then continue end
			-- TODO: Dont Render Self sometimes?

			local pos, ang = WorldToLocalBig(ent.Pos, ent.Ang, shipPos, shipAng)

			ent:Draw(camPos, pos, ang)
		end
	cam.End3D()
end

hook.Add("PostDraw2DSkyBox", "Star_Trek.World.Draw", function()
	--Star_Trek.World:Draw()
end)
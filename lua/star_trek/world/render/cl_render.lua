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
local VECTOR_MAX = 131071 -- TODO: Recheck

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
	if dir[2] < 0 then
		direction = 4
	end

	local yHit = IntersectPlaneAxis(pos, dir, direction)
	if yHit and math.abs(yHit[1]) < VECTOR_MAX and math.abs(yHit[3]) < VECTOR_MAX then
		return yHit
	end

	direction = 5
	if dir[3] < 0 then
		direction = 6
	end

	local zHit = IntersectPlaneAxis(pos, dir, direction)
	if zHit and math.abs(zHit[1]) < VECTOR_MAX and math.abs(zHit[2]) < VECTOR_MAX then
		return zHit
	end

	return false
end

local zero_vec = Vector()

-- Draws an object relative to you.
--
-- @param ClientsideEntity ent
-- @param Vector pos
-- @param Vector ang
function Star_Trek.World:DrawEntity(ent, pos, ang)
	local maxValue = math.max(
		math.abs(pos[1]),
		math.abs(pos[2]),
		math.abs(pos[3])
	)

	local modelScale = ent.Scale or 1
	if maxValue >= VECTOR_MAX then
		-- Outside of Maximum Regular Render Range.
		local vec = Vector(pos)

		local distance = vec:Length()
		vec:Normalize()

		pos = IntersectWithBorder(zero_vec, vec)
		if not pos then return end
		local projectedDistance = pos:Length()

		local factor = projectedDistance / distance
		ent:SetModelScale(modelScale * factor)
	else
		-- Inside of Maximum Regular Render Range
		if ent:GetModelScale() ~= modelScale then
			ent:SetModelScale(modelScale)
		end
	end

	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:DrawModel()
end

local eyePos
hook.Add("PreDrawSkyBox", "Star_Trek.World.Draw", function()
	eyePos = EyePos()
end)

function Star_Trek.World:Draw()
	local shipPos, shipAng = Star_Trek.World:GetShipPos()
	if not shipPos then return end

	local skyEyePos = eyePos * SKY_CAM_SCALE
	cam.Start3D(skyEyePos, EyeAngles(), nil, nil, nil, nil, nil, 0.0005, 10000000)
		render.SuppressEngineLighting(true)

		for i, ent in pairs(self.Entities) do
			if i == 1 then continue end

			local pos, ang = WorldToLocalBig(ent.Pos, ent.Ang, shipPos, shipAng)
			ent:Draw(pos, ang)
		end

		render.SuppressEngineLighting(false)
	cam.End3D()
end

hook.Add("PostDraw2DSkyBox", "Star_Trek.World.Draw", function()
	Star_Trek.World:Draw()
end)
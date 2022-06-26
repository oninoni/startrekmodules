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

-- Draws an object relative to you.
--
-- @param ClientsideEntity ent
-- @param Vector pos
-- @param Vector ang
function Star_Trek.World:DrawEntity(ent, pos, ang)
	local modelScale = ent.Scale or 1

	local distance = pos:Length()
	if distance > VECTOR_MAX then
		pos = Vector(pos)
		pos:Normalize()

		pos = pos * VECTOR_MAX
		ent:SetModelScale(modelScale * (VECTOR_MAX / distance))
	else
		ent:SetModelScale(modelScale)
	end

	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:DrawModel()
end

local skyCorners = {
	Vector( 1,  1,  1),
	Vector( 1,  1, -1),
	Vector( 1, -1,  1),
	Vector( 1, -1, -1),
	Vector(-1,  1,  1),
	Vector(-1,  1, -1),
	Vector(-1, -1,  1),
	Vector(-1, -1, -1),
}
local skyMaterials = {
	Material("skybox/sky_intrepidft"),
	Material("skybox/sky_intrepidbk"),
	Material("skybox/sky_intrepidrt"),
	Material("skybox/sky_intrepidlf"),
	Material("skybox/sky_intrepidup"),
	Material("skybox/sky_intrepiddn"),
}

function Star_Trek.World:DrawBackground()
	render.SetMaterial(skyMaterials[1])
	render.DrawQuad(
		skyCorners[3],
		skyCorners[7],
		skyCorners[8],
		skyCorners[4])

	render.SetMaterial(skyMaterials[2])
	render.DrawQuad(
		skyCorners[5],
		skyCorners[1],
		skyCorners[2],
		skyCorners[6])

	render.SetMaterial(skyMaterials[3])
	render.DrawQuad(
		skyCorners[1],
		skyCorners[3],
		skyCorners[4],
		skyCorners[2])

	render.SetMaterial(skyMaterials[4])
	render.DrawQuad(
		skyCorners[7],
		skyCorners[5],
		skyCorners[6],
		skyCorners[8])

	render.SetMaterial(skyMaterials[5])
	render.DrawQuad(
		skyCorners[5],
		skyCorners[7],
		skyCorners[3],
		skyCorners[1])

	render.SetMaterial(skyMaterials[6])
	render.DrawQuad(
		skyCorners[2],
		skyCorners[4],
		skyCorners[8],
		skyCorners[6])
end

local eyePos, eyeAngles
hook.Add("PreDrawSkyBox", "Star_Trek.World.Draw", function()
	eyePos, eyeAngles = EyePos(), EyeAngles()
end)

function Star_Trek.World:Draw()
	local shipPos, shipAng = Star_Trek.World:GetShipPos()
	if not shipPos then return end

	-- TODO: Optimise Sorting by doing it in a table less often.
	for _, ent in pairs(self.Entities) do
		ent.Distance = (ent.Pos - shipPos):Length()
	end

	render.SuppressEngineLighting(true)
	cam.IgnoreZ(true)

	local mat = Matrix()
	mat:SetAngles(shipAng)
	mat:Rotate(eyeAngles)
	cam.Start3D(Vector(), mat:GetAngles(), nil, nil, nil, nil, nil, 0.5, 2)
		self:DrawBackground()
	cam.End3D()

	cam.Start3D(eyePos * SKY_CAM_SCALE, eyeAngles, nil, nil, nil, nil, nil, 0.0005, 10000000)
		for i, ent in SortedPairsByMemberValue(self.Entities, "Distance", true) do
			if i == 1 then continue end

			local pos, ang = WorldToLocalBig(ent.Pos, ent.Ang, shipPos, shipAng)
			ent:Draw(pos, ang)
		end
	cam.End3D()

	cam.IgnoreZ(false)
	render.SuppressEngineLighting(false)
end

hook.Add("PostDraw2DSkyBox", "Star_Trek.World.Draw", function()
	Star_Trek.World:Draw()
end)
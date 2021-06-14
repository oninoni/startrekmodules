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
--           World | Client          --
---------------------------------------

-- Vector_Max in Skybox is  (2^17) 
-- @ x1024 (2^10) Scale -> Visually at 134217728 (2^27)
local VECTOR_MAX = 131072
local VECTOR_MAX_1 = VECTOR_MAX - 1
local BOX_MIN = Vector(-VECTOR_MAX_1, -VECTOR_MAX_1, -VECTOR_MAX_1)
local BOX_MAX = Vector( VECTOR_MAX_1,  VECTOR_MAX_1,  VECTOR_MAX_1)

-- Sky Cam is not Readable Clientside, which is absurd...
-- TODO: I can network it?
local SKY_CAM_POS = Vector(-4032, 0, 12800)
local SKY_CAM_SCALE = 1 / 1024

Star_Trek.World.Objects = {}

function Star_Trek.World:AddObject(i, pos, ang, scale, model, fullbright)
	local obj = {
		Pos = pos,
		Ang = ang,
		Scale = SKY_CAM_SCALE * scale,
		FullBright = fullbright,
	}

	obj.Ent = ClientsideModel(model)
	obj.Ent:SetNoDraw(true)
	obj.Ent:SetModelScale(obj.Scale)
	obj.Ent.Scale = obj.Scale

	self.Objects[i] = obj
end

function Star_Trek.World:UpdateObject(i, pos, ang)
	local obj = self.Objects[i]

	obj.Pos = pos
	obj.Ang = ang
end

function Star_Trek.World:RemoveObject(i)
	local obj = self.Objects[i]
	obj.Ent:Remove()

	self.Objects[i] = nil
end

local function IntersectPlaneAxis(pos, dir, axis)
--	local factor = ((VECTOR_MAX * axis + pos) / (pos * axis):Length()):Length()
--	print(factor)
--
--	return pos + dir * factor

	return util.IntersectRayWithPlane(pos, dir, axis * VECTOR_MAX_1, axis)
end

local function IntersectWithBorder(pos, dir)
	local xAxis = Vector(1, 0, 0)
	if dir.x < 0 then
		xAxis = -xAxis
	end

	local xHit = IntersectPlaneAxis(pos, dir, xAxis)
	if xHit and math.abs(xHit.y) < VECTOR_MAX and math.abs(xHit.z) < VECTOR_MAX then
		return xHit
	end

	local yAxis = Vector(0, 1, 0)
	if dir.x < 0 then
		xAxis = -yAxis
	end

	local yHit = IntersectPlaneAxis(pos, dir, yAxis)
	if yHit and math.abs(yHit.x) < VECTOR_MAX and math.abs(yHit.y) < VECTOR_MAX then
		return yHit
	end

	local zAxis = Vector(0, 0, 1)
	if dir.x < 0 then
		zAxis = -zAxis
	end

	local zHit = IntersectPlaneAxis(pos, dir, zAxis)
	if zHit and math.abs(zHit.x) < VECTOR_MAX and math.abs(zHit.y) < VECTOR_MAX then
		return zHit
	end

	return false
end

--[[
relPos
Position relativ zum Origin der Map
Scaled x1024

relWorldPos
Position realtiv zur Sky Kamera
Scaled x1024

EyePos()
Position relativ zum Origin der Map
Scaled x1

camPos 
Position relativ zur Sky Kamera
Scaled x1024

]]

-- Draws an object relative to you.
function Star_Trek.World:DrawEntity(ent, relPos, relAng)
	local relWorldPos = SKY_CAM_POS + relPos

	-- Check if in within Vector_Max
	local maxValue = math.max(
		math.abs(relWorldPos.x),
		math.abs(relWorldPos.y),
		math.abs(relWorldPos.z)
	)

	if maxValue >= VECTOR_MAX then
		local camPos = SKY_CAM_POS + (EyePos() * SKY_CAM_SCALE) -- TODO: Optimise into single call per Frame.

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

function Star_Trek.World:GetShipPos()
	return self.ShipPos, self.ShipAng
end

function Star_Trek.World:SetShipPos(pos, ang)
	self.ShipPos = pos or Vector()
	self.ShipAng = ang or Angle()
end

function Star_Trek.World:Draw()
	local shipPos, shipAng = Star_Trek.World:GetShipPos()

	cam.Start3D(EyePos(), EyeAngles(), nil, nil, nil, nil, nil, 0.001, 10000000)
		for i, obj in pairs(Star_Trek.World.Objects) do
			local pos, ang = WorldToLocal(obj.Pos, obj.Ang, shipPos, shipAng)

			if obj.FullBright then
				render.SetLightingMode(1)
			end
			Star_Trek.World:DrawEntity(obj.Ent, pos, ang)

			render.SetLightingMode(0)
		end
	cam.End3D()
end

hook.Add("PostDraw2DSkyBox", "Star_Trek.Testing", function()
	Star_Trek.World:Draw()
end)

Star_Trek.World:SetShipPos(Vector(0, 0, 4), Angle())

Star_Trek.World:AddObject(1, Vector(3000, 5000, 0), Angle(0, 0, 0), 1024, "models/sb_genesis_omega/planet2.mdl", true)
Star_Trek.World:AddObject(2, Vector(3000, 0, 2000), Angle(0, 90, -90), 512, "models/sb_genesis_omega/planet2.mdl", true)

Star_Trek.World:AddObject(3, Vector(0, 25, 0), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(4, Vector(0, 25, 0), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(5, Vector(0, -25, 0), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(6, Vector(0, -25, 0), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(7, Vector(0, 25, 25), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(8, Vector(0, 25, 25), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(9, Vector(0, -25, 25), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(10, Vector(0, -25, 25), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(11, Vector(0, 25, -25), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(12, Vector(0, 25, -25), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(13, Vector(0, -25, -25), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(14, Vector(0, -25, -25), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(15, Vector(0, 0, -25), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(16, Vector(0, 0, -25), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(17, Vector(0, 0, 25), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(18, Vector(0, 0, 25), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(50, Vector(0, 0, 6), Angle(0, 0, 180), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

local startTime = SysTime()
local SPEED = 200

hook.Add("Think", "Testing", function()
	local time = SysTime() - startTime

	--local speed = (Star_Trek.World.Objects[1].Pos):Length() * SPEED * (time / 10)

	Star_Trek.World:SetShipPos(Vector(-time * SPEED, 0, 4))

--	Star_Trek.World:UpdateObject(1, Vector(3000 + time * speed, 5000, 0), Angle())
--	Star_Trek.World:UpdateObject(3, Vector(0 + time * speed, 25, 0), Angle())
--	Star_Trek.World:UpdateObject(4, Vector(0 + time * speed, 25, 0), Angle())
end)






























-- lua_run for _, ent in pairs(ents.FindByModel("models/hunter/misc/sphere075x075.mdl")) do ent:Remove() end

--[[
Soooo...

I could do 1:1 Scale, but it would need probably a bit higher Skybox Scale (As much as possible).
Currently an earth sized object reaches Vector_Max very quickly.
Going a bit smaller with the world, would probably be fine.

Putting this into a system would need:
	- Data Structure. (Probably based on some tree model, to reduce networking, streaming in / out sectors, Maybe sorted by size, so big objects get loaded at higher distance ("Apparent diameter", Check for Visibility for Actual Objects and Check for Luminosity for "Dot" Version before.))
		- probably multi-vector Coordinates, to get rid of low precision lua floats.
		- Those will need to be taken into consideration serverside only, try to convert data to local area of ship for client? (No idea if this is needed., reduces networking tho.)
	- Ship Position, that controls what data is drawn.
	- Networking (To do Controls Serverside)
		- Detect, if a player actually needs the data right now, or if he's internal
		- "Do i see the Skybox" Might be as simple as checking clientside if the skybox hooks are called. (Lag tho, so might have to do serverside hackery)
	- Prediction? (probably only possible on ships for the pilot, so not worth it.)
		- Better to prioritise the movement of the ship in networking and make most other things stationary / move on predictable pathes.
		- Then we can reduce the frequency of the other data being sent and concentrate on the "main ships"
	- Keep Multiple Ships in Mind, to allow streaming Data from 2 Positions at once to two players.

	- Handle the Map Functionality:
		- Remove the "Default Asteroids and Stuff"
		- Probably fine to use the normal warp effect.

What i also need is:
	- Handle Objects very far away creating lights in the sky (Everything creates a certain ammount of light, visible for more than the resolution of the object.)
	- Handle Objects reaching Vector_Max while being still visible (Scaling at Vector_Max in the right direction using "Apparent diameter", needs some Pytagoras)
	- Handle Objects entering The Actual World. (To prevent near-clip)

Whish-Thinking:
	- Collisions? (Ask Star? Ask Possseidon? :D)
		- Simple Sphere Collisions should be enough, although Star's Implementation sounds intriguing.
	- 6 Degrees of Freedom
		- Technically its possible now, that i dont need the "normal skybox" anymore.
	- Optimize Rendering & Networking With Distance Sorting / Occlusion (priority on Networking)

Current TODO List:

- Start a simple Clientside Data Structure for Objects.
- Add Ship Position.
- Calculate "Apparent Size".
- Handle Objects Reaching Pixel Resolution. (Dont render for now)
- Handle Objects Reaching Vector_Max.

]]
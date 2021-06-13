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

--local skybox_scale = 1 / 1024
local skybox_scale = 1 / 1024

local enterprise = ClientsideModel("models/apwninthedarks_starship_pack/enterprise-e.mdl", RENDERGROUP_OPAQUE)
enterprise:SetNoDraw(true)
enterprise:SetModelScale(skybox_scale * 3)

local drydock = ClientsideModel("models/apwninthedarks_starship_pack/drydock_type_4.mdl")
drydock:SetNoDraw(true)
drydock:SetModelScale(skybox_scale * 3)

local planet = ClientsideModel("models/sb_genesis_omega/planet2.mdl")
planet:SetNoDraw(true)
planet:SetModelScale(64) -- That should be about the size of earth @ 1024x (9.8Mm ~ Earth is 12.7Mm)
planet:SetAngles(Angle(0, 0, 90))

local maxTime = 10 * math.pi
local sky_camera_pos = Vector(-4032, 0, 12800)

local pos = 0

-- Vector_Max in Skybox is 131072 (2^17) @ x1024 (2^10) Scale -> Visually at 134217728 (2^27)
-- Scale @ x1024

hook.Add("PostDraw2DSkyBox", "Star_Trek.Testing", function()
	cam.Start3D(EyePos(), EyeAngles(), nil, nil, nil, nil, nil, 0.001, 10000000)
		local time = SysTime() % maxTime

		pos = pos + ((1 + pos) * 1 * FrameTime())

		enterprise:SetPos(sky_camera_pos + Vector(pos, 10, 0))
		enterprise:DrawModel()

		drydock:SetPos(sky_camera_pos + Vector(pos, 10, -0.75))
		drydock:DrawModel()

		cam.IgnoreZ(true)
		render.SetLightingMode(1)
			planet:SetPos(sky_camera_pos + 1 * Vector(pos, 0, -131072 + 12800))
			--planet:SetPos(Vector(pos, 0, 9800))
			planet:SetAngles(planet:GetAngles() + Angle(-1 * FrameTime(), 0, 0))
			planet:DrawModel()
		render.SetLightingMode(0)
		cam.IgnoreZ(false)
	cam.End3D()
end)

--[[
local bigPlanet = ClientsideModel("models/sb_genesis_omega/planet2.mdl")
bigPlanet:SetNoDraw(true)
bigPlanet:SetModelScale(0.5)

hook.Add("PostDrawOpaqueRenderables", "Testing", function(d, sky, dSky)
	if not(sky or dSky) then return end

	cam.Start3D(EyePos(), EyeAngles(), nil, nil, nil, nil, nil, 0.001, 10000000)
	cam.IgnoreZ(true)
	render.SetLightingMode(1)
		bigPlanet:SetPos(Vector(pos, 1000, -60000))
		bigPlanet:DrawModel()
	render.SetLightingMode(0)
	cam.IgnoreZ(false)
	cam.End3D()
end)
]]



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
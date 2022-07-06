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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--           World | Index           --
---------------------------------------

Star_Trek:RequireModules()

Star_Trek.World = Star_Trek.World or {}

if SERVER then
	AddCSLuaFile("sh_config.lua")
	AddCSLuaFile("sh_loaders.lua")

	AddCSLuaFile("util/sh_convert.lua")
	AddCSLuaFile("util/sh_vector.lua")
	AddCSLuaFile("sh_entities.lua")

	AddCSLuaFile("net/cl_net.lua")
	AddCSLuaFile("render/cl_render.lua")
	AddCSLuaFile("render/cl_background.lua")
	AddCSLuaFile("cl_entities.lua")

	include("sh_config.lua")
	include("sh_loaders.lua")

	include("util/sh_convert.lua")
	include("util/sh_vector.lua")
	include("sh_entities.lua")

	include("net/sv_net.lua")
	include("sv_entities.lua")

	include("sv_world.lua")
end

if CLIENT then
	include("sh_config.lua")
	include("sh_loaders.lua")

	include("util/sh_convert.lua")
	include("util/sh_vector.lua")
	include("sh_entities.lua")

	include("net/cl_net.lua")
	include("render/cl_render.lua")
	include("render/cl_background.lua")
	include("cl_entities.lua")
end














--[[ TOPICS

Scale:

We can do 1:1 Scale. 
Question is should we?
Maybe talk to people about scale. <<<<


Data Structure:

{
	Pos = WorldVector,
	-- Position in the Galaxy.
	-- Using a World Vector, to allow numbers of up to 10^20 x1024 Units from Origin. (Big Enough for 1:1 Milky Way)
	
	Ang = Angle,
	-- Angle of the Object relative to Galactic North.

	VRange = Number, 
	-- Distance, at which the Object becomes a light point.

	Magnitude = Number,
	-- Brigthness of the Object as a light point, that determines from how far it can be seen. (Absolute Magnitude)
	
}








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

- Handle Objects Reaching Pixel Resolution. (Dont render for now)

]]
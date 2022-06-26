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
--      World Entities | Server      --
---------------------------------------

-- Load a given entity into the cache and networks to all players.
--
-- @param Number id
-- @param String class
-- @param vararg ...
-- @return Boolean success
-- @return String error
function Star_Trek.World:LoadEntity(id, class, ...)
	local successInit, ent = self:InitEntity(id, class, ...)
	if not successInit then
		return false, ent
	end

	local successNetwork, error = self:NetworkLoad(ent)
	if not successNetwork then
		return false, error
	end

	return true, ent
end

local function addTestingShip(id, pos)
	local success, worldEnt = Star_Trek.World:LoadEntity(id, "ship",
		WorldVector(0, 0, 0, pos.x, pos.y, pos.z),
		Angle(),
		{
			[1] = {
				Model = "models/hunter/blocks/cube1x1x1.mdl",
				Scale = 1 / 1024
			},
		}
	)

	if not success then
		return false, worldEnt
	end

	return worldEnt
end

local function addPlanet(id, pos, model, radius)
	local ent = ents.Create("prop_physics")
	ent:SetModel(model)
	ent:Spawn()

	local min, max = ent:GetModelBounds()
	ent:Remove()

	local scale = max - min
	local modelDiameter = math.max(
		math.abs(scale.x),
		math.abs(scale.y),
		math.abs(scale.z)
	)

	local size = radius / (modelDiameter / 2)

	local success, worldEnt = Star_Trek.World:LoadEntity(id, "planet",
		WorldVector(0, 0, 0, pos.x, pos.y, pos.z),
		Angle(),
		{
			[1] = {
				Model = model,
				Scale = size
			},
		}
	)

	if not success then
		return false, worldEnt
	end

	return worldEnt
end

local ship
timer.Simple(0, function()
	ship = addTestingShip(1, Vector(), Angle(), 1)
	--ship:SetVelocity(Vector(-Star_Trek.World:SkyboxMeter(300000000) * 8, 0, 0))

	local earthRadius = 6371000
	local earthDistance = earthRadius + 42164000
	local earthPos = Vector(0, Star_Trek.World:SkyboxMeter(earthDistance), 0)
	local earth = addPlanet(2, earthPos, "models/planets/earth.mdl", Star_Trek.World:SkyboxMeter(earthRadius))

	local moonRadius = 1737400
	local moonDistance = 356500000
	local moonPos = earthPos + Vector(-Star_Trek.World:SkyboxMeter(moonDistance), 0, 0)
	local moon = addPlanet(3, moonPos, "models/planets/luna_big.mdl", Star_Trek.World:SkyboxMeter(moonRadius))

	local sunRadius = 696340000
	local sunDistance = 150000000000
	local sunPos = earthPos + Vector(-Star_Trek.World:SkyboxMeter(sunDistance), 0, 0)
	local sun = addPlanet(4, sunPos, "models/planets/sun.mdl", Star_Trek.World:SkyboxMeter(sunRadius))
end)

hook.Add("Star_Trek.LCARS.BasicPressed", "WarpDrive.Weeee", function(ply, interfaceData, buttonId)
	local ent = interfaceData.Ent
	local name = ent:GetName()

	if name == "connBut4" then
		if buttonId == 1 then
			timer.Simple(2, function()
				ship:SetVelocity(Vector(-Star_Trek.World:SkyboxMeter(300000000), 0, 0))
			end)
		else
			timer.Simple(2, function()
				ship:SetVelocity(Vector(0, 0, 0))
			end)
		end
	end
end)

timer.Create("TestingSync", 1, 0, function()
	Star_Trek.World:NetworkSync()
end)

-- lua_run AddTestingShip(2, Vector(1, -10, -3), Angle(0, 180, 0), 1, Vector(1, 0, 0), Angle())

-- Networks all loaded entities for the new player.
hook.Add("PlayerInitialSpawn", "Star_Trek.World.NetworkLoaded", function(ply)
	Star_Trek.World:NetworkLoaded(ply)
end)

-- Unloads the given entity from the local cache.
--
-- @param Number id
-- @return Boolean success
-- @return String error
function Star_Trek.World:UnLoadEntity(id)
	local successTerminate, errorTerminate = self:TerminateEntity(id)
	if not successTerminate then
		return false, errorTerminate
	end

	local successNetwork, errorNetwork = self:NetworkUnLoad(id)
	if not successNetwork then
		return false, errorNetwork
	end

	return true
end
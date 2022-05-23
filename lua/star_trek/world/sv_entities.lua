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

local function addTestingShip(id, pos, ang, scale, temp)
	local success, ent = Star_Trek.World:LoadEntity(id, "ship",
		WorldVector(0, 0, 0, pos.x, pos.y, pos.z),
		ang,
		{
			[1] = {
				Model = "models/apwninthedarks_starship_pack/uss_defiant.mdl",
				Scale = (1 / 1024) * scale,
			},
		}
	)

	if not success then
		return false, ent
	end

	return ent
end

timer.Simple(0, function()
	local voyager = addTestingShip(1, Vector(), Angle(), 1)
	voyager:SetAcceleration(Vector(-8, 0, 0))

	local defiant = addTestingShip(2, Vector(-10, -4, -1), Angle(0, 0, 0), 2)
	defiant:SetAcceleration(Vector(-10, 0, 0))

	Star_Trek.World:LoadEntity(3, "planet", WorldVector(0, 0, 0, -500, 250, 150), Angle())
	Star_Trek.World:LoadEntity(4, "planet", WorldVector(0, 0, 0, 700, 150, 150), Angle(0, 20, 34))
	Star_Trek.World:LoadEntity(5, "planet", WorldVector(0, 0, 0, 0, 0, -110), Angle())
	Star_Trek.World:LoadEntity(6, "planet", WorldVector(0, 0, 0, 0, -500, 0), Angle())
end)

timer.Simple(3, function()
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
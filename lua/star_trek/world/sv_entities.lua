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

	local successNetwork, error = self:NetworkLoad(id, ent)
	if not successNetwork then
		return false, error
	end

	return true
end

function AddTestingShip(id, pos, ang, scale, vel, angVel)
	print(Star_Trek.World:LoadEntity(id, "ship",
		WorldVector(0, 0, 0, pos.x, pos.y, pos.z),
		ang,
		{
			[1] = {
				Model = "models/apwninthedarks_starship_pack/uss_defiant.mdl",
				Scale = (1 / 1024) * scale,
			},
		},
		vel,
		angVel
	))
end

timer.Simple(2, function()
	AddTestingShip(1, Vector(), Angle(), 0, Vector(0, 0, 0), Angle(0, 0, 0))
end)

timer.Simple(3, function()
	AddTestingShip(2, Vector(-10, 2, -1), Angle(0, 0, 0), 2, Vector(0, 0, 0), Angle(0, 0, 0))
	AddTestingShip(3, Vector(-8, -2, -2), Angle(0, 0, 0), 2, Vector(0, 0, 0), Angle(0, 0, 0))
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
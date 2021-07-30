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
-- @param Table data
-- @return Boolean success
-- @return String error
function Star_Trek.World:LoadEntity(id, class, data)
	local successInit, ent = self:InitEntity(id, class, data)
	if not successInit then
		return false, ent
	end

	local successNetwork, error = self:NetworkLoad(id, ent)
	if not successNetwork then
		return false, error
	end

	return true
end

function AddTestingShip(id, pos, ang, scale)
	print(Star_Trek.World:LoadEntity(id, "ship", {
		Pos = WorldVector(Vector(), pos),
		Ang = ang,
		Vel = Vector(),
		AngVel = Vector(),
		Models = {
			[1] = {
				Model = "models/apwninthedarks_starship_pack/uss_defiant.mdl",
				Scale = (1 / 1024) * scale,
			},
		}
	}))
end


timer.Simple(2, function()
	AddTestingShip(1, Vector(), Angle(), 0)
end)

-- lua_run AddTestingShip(2, Vector(1, -10, -3), Angle(0, 180, 0), 6)



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
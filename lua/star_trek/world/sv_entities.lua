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

timer.Create("TestingSync", 1, 0, function()
	Star_Trek.World:NetworkSync()
end)

-- Networks all loaded entities for the new player.
hook.Add("PlayerInitialSpawn", "Star_Trek.World.NetworkLoaded", function(ply)
	Star_Trek.World:NetworkLoaded(ply)
end)

-- Remove the map based sun effect for now.
hook.Add("InitPostEntity", "Star_Trek.World.RemoveMapSun", function(ply)
	local entities = ents.FindByClass("env_sun")
	for _, ent in pairs(entities) do
		ent:Remove()
	end
end)
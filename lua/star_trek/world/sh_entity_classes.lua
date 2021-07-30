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
--   World Entitiy Classes | Shared  --
---------------------------------------

-- Load a given world entity.
--
-- @param String moduleName
-- @param String worldEntityDirectory
-- @param String worldEntityClass
-- @return Boolean success
-- @return String error
function Star_Trek.World:LoadWorldEntityClass(moduleName, worldEntityDirectory, worldEntityClass)
	ENT = {}
	ENT.Class = worldEntityClass

	local success = pcall(function()
		if SERVER then
			AddCSLuaFile(worldEntityDirectory .. "/" .. worldEntityClass .. "/shared.lua")
			AddCSLuaFile(worldEntityDirectory .. "/" .. worldEntityClass .. "/cl_init.lua")

			include(worldEntityDirectory .. "/" .. worldEntityClass .. "/shared.lua")
			include(worldEntityDirectory .. "/" .. worldEntityClass .. "/init.lua")
		end
		if CLIENT then
			include(worldEntityDirectory .. "/" .. worldEntityClass .. "/shared.lua")
			include(worldEntityDirectory .. "/" .. worldEntityClass .. "/cl_init.lua")
		end
	end)
	if not success then
		return false, "Cannot load World Entity Class \"" .. worldEntityClass .. "\" from module " .. moduleName
	end

	local baseWorldEntityClass = ENT.BaseClass
	if isstring(baseWorldEntityClass) then
		timer.Simple(0, function()
			local baseWorldEntity = self.EntityClasses[baseWorldEntityClass]
			if istable(baseWorldEntity) then
				self.EntityClasses[worldEntityClass].Base = baseWorldEntity
				setmetatable(self.EntityClasses[worldEntityClass], {__index = baseWorldEntity})
			else
				Star_Trek:Message("Failed, to load Base World Entity Class \"" .. baseWorldEntity .. "\"")
			end
		end)
	end

	self.EntityClasses[worldEntityClass] = ENT
	ENT = nil

	return true
end

-- Load entity classes from all modules.
hook.Add("Star_Trek.LoadModule", "Star_Trek.World.LoadWorldEntities", function(moduleName, moduleDirectory)
	Star_Trek.World.EntityClasses = Star_Trek.World.EntityClasses or {}

	local worldEntityDirectory = moduleDirectory .. "world_entities/"
	local _, worldEntityDirectories = file.Find(worldEntityDirectory .. "*", "LUA")
	for _, worldEntityClass in pairs(worldEntityDirectories) do
		local success, error = Star_Trek.World:LoadWorldEntityClass(moduleName, worldEntityDirectory, worldEntityClass)
		if success then
			Star_Trek:Message("Loaded World Entity Class \"" .. worldEntityClass .. "\" from module " .. moduleName)
		else
			Star_Trek:Message(error)
		end
	end
end)

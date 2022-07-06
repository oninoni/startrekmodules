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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--  World Entities Loaders | Shared  --
---------------------------------------

-- Load the given world entity class.
--
-- @param String entityDirectory
-- @param String entityName
-- @return Boolean success
-- @return? String error
function Star_Trek.World:LoadEntityClass(entityDirectory, entityName)
	local oldEnt = ENT

	ENT = {}
	ENT.Class = entityName

	local success = pcall(function()
		if SERVER then
			AddCSLuaFile(entityDirectory .. entityName .. "/shared.lua")
			AddCSLuaFile(entityDirectory .. entityName .. "/cl_init.lua")

			include(entityDirectory .. entityName .. "/shared.lua")
			include(entityDirectory .. entityName .. "/init.lua")
		end

		if CLIENT then
			include(entityDirectory .. entityName .. "/shared.lua")
			include(entityDirectory .. entityName .. "/cl_init.lua")
		end
	end)
	if not success then
		return false, "Cannot load World Entity Class \"" .. entityName .. "\""
	end

	self.EntityClasses[entityName] = ENT
	ENT = oldEnt

	return true
end

-- Reload all world entity classes.
--
-- @param String moduleDirectory
function Star_Trek.World:LoadEntityClasses(moduleDirectory)
	self.EntityClasses = self.EntityClasses or {}

	local entityDirectory = moduleDirectory .. "world_entities/"
	local _, entityDirectories = file.Find(entityDirectory .. "*", "LUA")

	for _, entityName in pairs(entityDirectories) do
		self.EntityClasses[entityName] = nil

		local success, error = self:LoadEntityClass(entityDirectory, entityName)
		if success then
			Star_Trek:Message("Loaded World Entity Class \"" .. entityName .. "\"")
		else
			Star_Trek:Message(error)
		end
	end
end

-- Link all the entity classes with their dependencies.
function Star_Trek.World:LinkEntityClasses()
	for entityName, entityClass in pairs(self.EntityClasses) do
		local baseEntityClass = entityClass.BaseClass
		if isstring(baseEntityClass) then
			local baseEntityClassObject = self.EntityClasses[baseEntityClass]
			if istable(baseEntityClassObject) then
				entityClass.Base = baseEntityClassObject
				setmetatable(entityClass, {__index = baseEntityClassObject})
			else
				Star_Trek:Message("Failed, to find Base World Entity Class \"" .. baseEntityClass .. "\" for \"" .. entityName .. "\"")
			end
		end
	end
end

------------------------
--        Hooks       --
------------------------

hook.Add("Star_Trek.ModuleLoaded", "Star_Trek.World.ReloadOnModuleLoaded", function(_, moduleDirectory)
	Star_Trek.World:LoadEntityClasses(moduleDirectory)
end)

hook.Add("Star_Trek.ModulesLoaded", "Star_Trek.World.ReloadOnModulesLoaded", function()
	Star_Trek.World:LinkEntityClasses()
end)
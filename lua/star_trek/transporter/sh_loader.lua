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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--        Transporter | Loader       --
---------------------------------------

-- Load the given Transporter Cycle Class.
--
-- @param String cycleDirectory
-- @param String cycleName
-- @return Boolean success
-- @return? String error
function Star_Trek.Transporter:LoadTransporterCycle(cycleDirectory, cycleName)
	CYCLE = {}
	CYCLE.Class = cycleName

	local success = pcall(function()
		if SERVER then
			AddCSLuaFile(cycleDirectory .. cycleName .. "/shared.lua")
			AddCSLuaFile(cycleDirectory .. cycleName .. "/cl_init.lua")

			include(cycleDirectory .. cycleName .. "/shared.lua")
			include(cycleDirectory .. cycleName .. "/init.lua")
		end

		if CLIENT then
			include(cycleDirectory .. cycleName .. "/shared.lua")
			include(cycleDirectory .. cycleName .. "/cl_init.lua")
		end
	end)
	if not success then
		return false, "Cannot load Transporter Cycle Class \"" .. cycleName .. "\""
	end

	self.Cycles[cycleName] = CYCLE
	CYCLE = nil

	return true
end

------------------------
--        Hooks       --
------------------------

-- Reload all Transporter Cycles of a module.
--
-- @param String moduleDirectory
function Star_Trek.Transporter:Reload(moduleDirectory)
	self.Cycles = self.Cycles or {}

	local cycleDirectory = moduleDirectory .. "transporter_cycles/"
	local _, cycleDirectories = file.Find(cycleDirectory .. "*", "LUA")

	for _, cycleName in pairs(cycleDirectories) do
		self.Cycles[cycleName] = nil

		local success, error = self:LoadTransporterCycle(cycleDirectory, cycleName)
		if success then
			Star_Trek:Message("Loaded Transporter Cycle Class \"" .. cycleName .. "\"")
		else
			Star_Trek:Message(error)
		end
	end
end

hook.Add("Star_Trek.ModuleLoaded", "Star_Trek.Transporter.ReloadOnModuleLoaded", function(_, moduleDirectory)
	Star_Trek.Transporter:Reload(moduleDirectory)
end)

-- Link all the Transporter Cycles to their Base Classes. 
function Star_Trek.LCARS:LinkDependencies()
	for cycleName, cycle in pairs(self.Cycles) do
		local baseCycleClass = cycle.BaseCycle
		if isstring(baseCycleClass) then
			local baseCycle = self.Cycles[baseCycleClass]
			if istable(baseCycle) then
				cycle.Base = baseCycle
				setmetatable(cycle, {__index = baseCycle})
			else
				Star_Trek:Message("Failed, to find Base Transporter Cycle Class \"" .. baseCycleClass .. "\" for \"" .. cycleName .. "\"")
			end
		end
	end
end

hook.Add("Star_Trek.ModulesLoaded", "Star_Trek.Transporter.ReloadOnModulesLoaded", function()
	Star_Trek.Transporter:LinkDependencies()
end)
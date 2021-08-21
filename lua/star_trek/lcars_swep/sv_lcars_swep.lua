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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--        LCARS SWEP | Server        --
---------------------------------------

--[[
hook.Add("Star_Trek.LCARS.IsPrivate", "Star_Trek.LCARS_SWEP.MakePrivate", function(ply, ent, interfaceData)
	if IsValid(ent) and ent:IsWeapon() and ent.IsLCARS then
		return true
	end
end)
]]

-- Load a given mode.
--
-- @param String moduleName
-- @param String modeDirectory
-- @param String modeName
-- @return Boolean success
-- @return String error
function Star_Trek.LCARS_SWEP:LoadMode(moduleName, modeDirectory, modeName)
	MODE = {}

	local success = pcall(function()
		include(modeDirectory .. "/" .. modeName .. "/init.lua")
	end)
	if not success then
		return false, "Cannot load LCARS Mode Type \"" .. modeName .. "\" from module " .. moduleName
	end

	local baseMode = MODE.BaseMode
	if isstring(baseMode) then
		timer.Simple(0, function()
			local baseModeData = self.Modes[baseMode]
			if istable(baseModeData) then
				self.Modes[modeName].Base = baseModeData
				setmetatable(self.Modes[modeName], {__index = baseModeData})
			else
				Star_Trek:Message("Failed, to load Base Mode \"" .. baseMode .. "\"")
			end
		end)
	end

	self.Modes[modeName] = MODE
	MODE = nil

	return true
end

hook.Add("Star_Trek.LoadModule", "Star_Trek.LCARS_SWEP.LoadModes", function(moduleName, moduleDirectory)
	Star_Trek.LCARS_SWEP.Modes = Star_Trek.LCARS_SWEP.Modes or {}

	local modeDirectory = moduleDirectory .. "modes/"
	local _, modeDirectories = file.Find(modeDirectory .. "*", "LUA")
	for _, modeName in pairs(modeDirectories) do
		local success, error = Star_Trek.LCARS_SWEP:LoadMode(moduleName, modeDirectory, modeName)
		if success then
			Star_Trek:Message("Loaded LCARS Mode Type \"" .. modeName .. "\" from module " .. moduleName)
		else
			Star_Trek:Message(error)
		end
	end
end)
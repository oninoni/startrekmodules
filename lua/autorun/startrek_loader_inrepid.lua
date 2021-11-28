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
--         Star Trek | Loader        --
---------------------------------------

game.AddParticles( "particles/intrepid_map.pcf" )

--[[
-- Some Code to quickly close and re-open lcars if changes to their keyvalues are made
hook.Add("Star_Trek.ChangedKeyValue", "Testing", function(ent, key, value)

	if not IsValid(ent) then return end
	
    ent:Fire("CloseLcars")

    timer.Simple(1, function()
		if not IsValid(ent) then return end
        ent:Fire("Press")
    end)
end)
]]

--[[
local skip = true

local convar = CreateConVar("star_trek_enable", "0")
if convar:GetBool() then
	skip = false
end

local detectMapStrings = {
	"rp_voyager",
	"rp_intrepid_v",
	"rp_intrepid_dev_v",
}
for _, mapString in pairs(detectMapStrings) do
	if string.StartWith(game.GetMap(), mapString) then
		skip = false
		continue
	end
end

if skip then return end
]]

-- TODO: Rework all "if not success", to display the Error properly. (Mostly Net, Hook and Clientside Errors)
-- TODO: Check if all errors are caught.
-- TODO: LCARS Alert Animation Rework

Star_Trek = Star_Trek or {}
Star_Trek.Modules = Star_Trek.Modules or {}
Star_Trek.LoadedModules = Star_Trek.LoadedModules or {}

function Star_Trek:Message(msg)
	if msg then
		MsgC(Color(255, 255, 0), "[Star Trek] " .. msg .. "\n")
	end
end

function Star_Trek:LoadModule(name)
	if Star_Trek.LoadedModules[name] then return end

	local moduleDirectory = "star_trek/" .. name .. "/"

	if SERVER then
		AddCSLuaFile(moduleDirectory .. "sh_index.lua")
	end
	include(moduleDirectory .. "sh_index.lua")

	local entityDirectory = moduleDirectory .. "entities/"
	local _, entityDirectories = file.Find(entityDirectory .. "*", "LUA")
	for _, entityName in pairs(entityDirectories) do
		local entDirectory = entityDirectory .. entityName .. "/"

		local oldEnt = ENT
		ENT = {
			ClassName = entityName,
			Folder = "entities/" .. entityName,
		}

		if SERVER then
			AddCSLuaFile(entDirectory .. "shared.lua")
			AddCSLuaFile(entDirectory .. "cl_init.lua")

			include(entDirectory .. "shared.lua")
			include(entDirectory .. "init.lua")
		end

		if CLIENT then
			include(entDirectory .. "shared.lua")
			include(entDirectory .. "cl_init.lua")
		end

		scripted_ents.Register(ENT, entityName)
		ENT = oldEnt

		Star_Trek:Message("Loaded Entity \"" .. entityName .. "\"")
	end

	local weaponDirectory = moduleDirectory .. "weapons/"
	local _, weaponDirectories = file.Find(weaponDirectory .. "*", "LUA")
	for _, weaponName in pairs(weaponDirectories) do
		local wepDirectory = weaponDirectory .. weaponName .. "/"

		local oldSWEP = SWEP
		SWEP = {
			ClassName = weaponName,
			Folder = "weapons/" .. weaponName,
			Primary = {},
			Secondary = {},
		}

		if SERVER then
			AddCSLuaFile(wepDirectory .. "shared.lua")
			AddCSLuaFile(wepDirectory .. "cl_init.lua")

			include(wepDirectory .. "shared.lua")
			include(wepDirectory .. "init.lua")
		end

		if CLIENT then
			include(wepDirectory .. "shared.lua")
			include(wepDirectory .. "cl_init.lua")
		end

		weapons.Register(SWEP, weaponName)
		SWEP = oldSWEP

		Star_Trek:Message("Loaded Weapon \"" .. weaponName .. "\"")
	end

	hook.Run("Star_Trek.LoadModule", name, moduleDirectory)

	Star_Trek.LoadedModules[name] = true

	Star_Trek:Message("Loaded Module \"" .. name .. "\"")
end

function Star_Trek:RequireModules(...)
	for _, moduleName in pairs({...}) do
		if Star_Trek.Modules[moduleName] then
			self:LoadModule(moduleName)
		else
			self:Message("Module \"" .. moduleName .. "\" is required! Please enable it!")
		end
	end
end

hook.Add("PostGamemodeLoaded", "Star_Trek.Load", function()
	if SERVER then
		AddCSLuaFile("star_trek/config.lua")
	end

	Star_Trek.LoadedModules = {}

	include("star_trek/config.lua")

	for moduleName, enabled in pairs(Star_Trek.Modules) do
		if enabled then
			Star_Trek:LoadModule(moduleName)
		end
	end
end)
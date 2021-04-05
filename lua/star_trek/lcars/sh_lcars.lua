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
--           LCARS | Shared          --
---------------------------------------

Star_Trek.LCARS.ActiveInterfaces = Star_Trek.LCARS.ActiveInterfaces or {}

function Star_Trek.LCARS:LoadWindow(windowName)
	if istable(self.Windows[windowName]) then
		return true, self.Windows[windowName]
	end

	WINDOW = {}

	AddCSLuaFile("windows/" .. windowName .. "/shared.lua")
	include("windows/" .. windowName .. "/shared.lua")

	if SERVER then
		AddCSLuaFile("windows/" .. windowName .. "/cl_init.lua")
		include("windows/" .. windowName .. "/init.lua")
	end
	if CLIENT then
		include("windows/" .. windowName .. "/cl_init.lua")
	end

	local window = WINDOW
	WINDOW = nil

	if isstring(window.BaseWindow) then
		local success, baseWindow = self:LoadWindow(window.BaseWindow)
		if not success then
			return false, baseWindow
		end

		window.Base = baseWindow
		setmetatable(window, {__index = baseWindow})
	end

	self.Windows[windowName] = window

	return true, self.Windows[windowName]
end

function Star_Trek.LCARS:LoadWindows()
	self.Windows = {}

	local _, directories = file.Find("star_trek/lcars/windows/*", "LUA")

	for _, windowName in pairs(directories) do
		local success, window = self:LoadWindow(windowName)
		if success then
			Star_Trek:Message("Loaded LCARS Window Type \"" .. windowName .. "\"")
		else
			Star_Trek:Message(window)
		end
	end
end

Star_Trek.LCARS:LoadWindows()
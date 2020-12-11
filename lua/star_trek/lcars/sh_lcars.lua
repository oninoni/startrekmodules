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

Star_Trek.LCARS.Windows = {}
Star_Trek.LCARS.ActiveInterfaces = Star_Trek.LCARS.ActiveInterfaces or {}

function Star_Trek.LCARS:LoadWindows()
	local _, directories = file.Find("star_trek/lcars/windows/*", "LUA")

	for _, windowName in pairs(directories) do
		WINDOW = {}

		if SERVER then
			AddCSLuaFile("windows/" .. windowName .. "/cl_init.lua")
			include("windows/" .. windowName .. "/init.lua")
		end
		if CLIENT then
			include("windows/" .. windowName .. "/cl_init.lua")
		end

		self.Windows[windowName] = WINDOW

		Star_Trek:Message("Loaded LCARS Window Type \"" .. windowName .. "\"")
	end
end

Star_Trek.LCARS:LoadWindows()
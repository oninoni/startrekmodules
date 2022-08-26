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
--    LCARS Logs Console | Server    --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

include("util.lua")

SELF.BaseInterface = "base"

SELF.LogType = "Logs Console"

function SELF:Open(ent)
	local success1, categorySelection = self:CreateCategorySelectionWindow()
	if not success1 then
		return false, categorySelection
	end

	local success2, controlWindow = self:CreateControlMenu()
	if not success2 then
		return false, controlWindow
	end

	local success3, listWindow = self:CreateListWindow(1)
	if not success3 then
		return false, listWindow
	end

	local success4, logWindow = Star_Trek.LCARS:CreateWindow(
		"log_entry",
		Vector(0, -2, -14.25),
		Angle(0, 0, 0),
		16,
		770,
		380,
		function(windowData, interfaceData, ply, buttonId)
		end,
		true
	)
	if not success4 then
		return false, logWindow
	end

	return true, {categorySelection, controlWindow, listWindow, logWindow}
end
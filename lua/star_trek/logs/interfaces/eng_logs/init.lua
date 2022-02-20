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
--   LCARS Bridge Security | Server  --
---------------------------------------

include("util.lua")

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = "base"

function SELF:Open(ent)
	local buttons = {}
	local success1, categorySelection = Star_Trek.LCARS:CreateWindow(
		"button_list",
		Vector(-12, -2, -14.25),
		Angle(0, 0, 0),
		24,
		575,
		570,
		function(windowData, interfaceData, buttonId)

		end,
		buttons,
		"Categories",
		"CTGRS",
		false
	)
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
		"text_entry",
		Vector(15, -26.25, 2.5),
		Angle(0, 0, -76.5),
		nil,
		600,
		600,
		function(windowData, interfaceData, buttonId)

		end,
		Color(255, 255, 255),
		"Logs",
		nil,
		true
	)
	if not success4 then
		return false, logWindow
	end

	return true, {categorySelection, controlWindow, listWindow, logWindow}
end

function SELF:GetData()
end
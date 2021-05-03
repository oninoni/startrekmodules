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
--     LCARS Transporter | Server    --
---------------------------------------

include("util.lua")
include("windowUtil.lua")

local SELF = INTERFACE
SELF.BaseInterface = "base"

function SELF:Open(ent)
	local padNumber = false
	local consoleName = ent:GetName()
	if isstring(consoleName) and string.StartWith(consoleName, "TRConsole") then
		local split = string.Split(consoleName, "_")
		padNumber = tonumber(split[2])
	end

	local success2, sourceMenuTable = self:CreateWindowTable(
		Vector(-13, -2, 6),
		Angle(5, 15, 30),
		350,
		false,
		Vector(-31, -12, 17),
		Angle(15, 45, 60),
		500,
		500,
		false,
		false,
		padNumber
	)
	if not success2 then
		return false, sourceMenuTable
	end
	local success3, error = sourceMenuTable:SelectType(sourceMenuTable.MenuTypes[1])
	if not success3 then
		return false, error
	end

	local success4, targetMenuTable = self:CreateWindowTable(
		Vector(13, -2, 6),
		Angle(-5, -15, 30),
		350,
		false,
		Vector(31, -12, 17),
		Angle(-15, -45, 60),
		500,
		500,
		false,
		true,
		padNumber
	)
	if not success4 then
		return false, targetMenuTable
	end
	local success5, error2 = targetMenuTable:SelectType(targetMenuTable.MenuTypes[1])
	if not success5 then
		return false, error2
	end

	local success6, sliderWindow = Star_Trek.LCARS:CreateWindow(
		"transport_slider",
		Vector(0, 0, 0),
		Angle(0, 0, 0),
		30,
		200,
		200,
		function(windowData, interfaceData, buttonId)
			self:TriggerTransporter(sourceMenuTable, targetMenuTable)
		end
	)
	if not success6 then
		return false, sliderWindow
	end

	return true, {sourceMenuTable.MenuWindow, sourceMenuTable.MainWindow, targetMenuTable.MenuWindow, targetMenuTable.MainWindow, sliderWindow}
end

-- Wrap for use in Map.
function Star_Trek.LCARS:OpenTransporterMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "transporter")
end
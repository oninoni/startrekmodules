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
-- LCARS Bridge Transporter | Server --
---------------------------------------

local SELF = INTERFACE
SELF.BaseInterface = "transporter"

function SELF:Open(ent)
	local success2, sourceMenuTable = self:CreateWindowTable(
		Vector(-22, -34, 8.2),
		Angle(0, 0, -90),
		500,
		false,
		Vector(-28, -5, -2),
		Angle(0, 0, 0),
		500,
		700,
		false,
		false
	)
	if not success2 then
		Star_Trek:Message(sourceMenuTable)
		return
	end
	local success3, error = sourceMenuTable:SelectType(sourceMenuTable.MenuTypes[1])
	if not success3 then
		Star_Trek:Message(error)
		return
	end

	local success4, targetMenuTable = self:CreateWindowTable(
		Vector(22, -34, 8.2),
		Angle(0, 0, -90),
		500,
		true,
		Vector(28, -5, -2),
		Angle(0, 0, 0),
		500,
		700,
		true,
		true
	)
	if not success4 then
		Star_Trek:Message(targetMenuTable)
		return
	end
	local success5, error2 = targetMenuTable:SelectType(targetMenuTable.MenuTypes[2])
	if not success5 then
		Star_Trek:Message(error2)
		return
	end

	local success6, sliderWindow = Star_Trek.LCARS:CreateWindow(
		"transport_slider",
		Vector(0, -34, 8),
		Angle(0, 0, -90),
		20,
		200,
		200,
		function(windowData, interfaceData, buttonId)
			self:TriggerTransporter(sourceMenuTable, targetMenuTable)
		end
	)
	if not success6 then
		Star_Trek:Message(sliderWindow)
		return
	end

	return {sourceMenuTable.MenuWindow, sourceMenuTable.MainWindow, targetMenuTable.MenuWindow, targetMenuTable.MainWindow, sliderWindow}
end

function Star_Trek.LCARS:OpenConsoleTransporterMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "bridge_transporter")
end
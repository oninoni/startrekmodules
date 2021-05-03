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

function SELF:OpenInternal(menuPos, menuAngle, menuWidth, mainPos, mainAngle, mainWidth, mainHeight, sliderPos, sliderAngle, textPos, textAngle, padNumber)
	local menuPosSource = menuPos + Vector()
	local menuPosTarget = menuPos + Vector()
	menuPosTarget.x = -menuPosTarget.x

	local menuAngleSource = menuAngle + Angle()
	local menuAngleTarget = menuAngle + Angle()
	menuAngleTarget.p = -menuAngleTarget.p
	menuAngleTarget.y = -menuAngleTarget.y

	local mainPosSource = mainPos + Vector()
	local mainPosTarget = mainPos + Vector()
	mainPosTarget.x = -mainPosTarget.x

	local mainAngleSource = mainAngle + Angle()
	local mainAngleTarget = mainAngle + Angle()
	mainAngleTarget.p = -mainAngleTarget.p
	mainAngleTarget.y = -mainAngleTarget.y

	local sourceSuccess, sourceMenuTable = self:CreateWindowTable(
		menuPosSource, menuAngleSource, menuWidth,
		mainPosSource, mainAngleSource, mainWidth, mainHeight,
		false, false, padNumber
	)
	if not sourceSuccess then
		return false, sourceMenuTable
	end

	local targetSuccess, targetMenuTable = self:CreateWindowTable(
		menuPosTarget, menuAngleTarget, menuWidth,
		mainPosTarget, mainAngleTarget, mainWidth, mainHeight,
		true , true , padNumber
	)
	if not targetSuccess then
		return false, targetMenuTable
	end

	-- For Reference
	sourceMenuTable.TargetMenuTable = targetMenuTable
	targetMenuTable.SourceMenuTable = sourceMenuTable

	local sliderSuccess, sliderWindow = Star_Trek.LCARS:CreateWindow(
		"transport_slider",
		sliderPos,
		sliderAngle,
		30,
		200,
		200,
		function(windowData, interfaceData, buttonId)
			self:TriggerTransporter(sourceMenuTable, targetMenuTable)
		end
	)
	if not sliderSuccess then
		return false, sliderWindow
	end

	local textSuccess, textWindow = Star_Trek.LCARS:CreateWindow(
		"text_entry",
		textPos,
		textAngle,
		24,
		550,
		720,
		function(windowData, interfaceData, categoryId, buttonId)
			return false
		end,
		Color(255, 255, 255),
		"Log File",
		"LOG",
		false
	)
	if not textSuccess then
		return false, textWindow
	end

	return true, {sourceMenuTable.MenuWindow, sourceMenuTable.MainWindow, targetMenuTable.MenuWindow, targetMenuTable.MainWindow, sliderWindow, textWindow}
end

function SELF:Open(ent)
	local padNumber = false
	local consoleName = ent:GetName()
	if isstring(consoleName) and string.StartWith(consoleName, "TRConsole") then
		local split = string.Split(consoleName, "_")
		padNumber = tonumber(split[2])
	end

	local success, windows = self:OpenInternal(
		Vector(-13, -2, 6),
		Angle(5, 15, 30),
		350,
		Vector(-31, -12, 17),
		Angle(15, 45, 60),
		500,
		500,
		Vector(0, 0, 0),
		Angle(0, 0, 0),
		Vector(0, -115, 70),
		Angle(0, 180, 110),
		padNumber
	)
	if not success then
		return false, windows
	end

	return true, windows
end

-- Wrap for use in Map.
function Star_Trek.LCARS:OpenTransporterMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "transporter")
end
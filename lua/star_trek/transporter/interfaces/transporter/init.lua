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

function SELF:OpenInternal(menuPos, menuAngle, menuWidth, mainPos, mainAngle, mainWidth, mainHeight, sliderPos, sliderAngle, textPos, textAngle, textWidth, textHeight, padNumber)
	local menuPosSource = menuPos + Vector()
	local menuPosTarget = menuPos + Vector()
	menuPosTarget[1] = -menuPosTarget[1]

	local menuAngleSource = menuAngle + Angle()
	local menuAngleTarget = menuAngle + Angle()
	menuAngleTarget.p = -menuAngleTarget.p
	menuAngleTarget[2] = -menuAngleTarget[2]

	local mainPosSource = mainPos + Vector()
	local mainPosTarget = mainPos + Vector()
	mainPosTarget[1] = -mainPosTarget[1]

	local mainAngleSource = mainAngle + Angle()
	local mainAngleTarget = mainAngle + Angle()
	mainAngleTarget.p = -mainAngleTarget.p
	mainAngleTarget[2] = -mainAngleTarget[2]

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

	local textSuccess, textWindow = Star_Trek.LCARS:CreateWindow(
		"text_entry",
		textPos,
		textAngle,
		24,
		textWidth,
		textHeight,
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

	local sliderSuccess, sliderWindow = Star_Trek.LCARS:CreateWindow(
		"transport_slider",
		sliderPos,
		sliderAngle,
		30,
		200,
		200,
		function(windowData, interfaceData, buttonId)
			self:TriggerTransporter(sourceMenuTable, targetMenuTable, textWindow)
		end
	)
	if not sliderSuccess then
		return false, sliderWindow
	end

	return true, {sourceMenuTable.MenuWindow, sourceMenuTable.MainWindow, targetMenuTable.MenuWindow, targetMenuTable.MainWindow, sliderWindow, textWindow}
end

function SELF:Open(ent)
	local padNumber = false
	local consoleName = ent:GetName()
	if isstring(consoleName) and string.StartWith(consoleName, "TRButton") then
		local split = string.Split(consoleName, "_")
		padNumber = tonumber(split[2])
	end

	local success, windows = self:OpenInternal(
		Vector(-13, 0, 6),
		Angle(20, 0, -20),
		350,
		Vector(-30, 4, 19),
		Angle(55, 0, -20),
		500,
		500,
		Vector(0, -4, -0.5),
		Angle(0, 0, -68),
		Vector(22, 24.5, 126.5),
		Angle(192, 0, 0),
		670,
		650,
		padNumber
	)
	if not success then
		return false, windows
	end

	return true, windows
end

-- Read out any Data, that can be retrieved externally.
--
-- @return? Table data
function SELF:GetData()
	local data = {}

	data.LogData = self.Windows[6].Lines
	data.LogTitle = "Transporter"

	return data
end

-- Wrap for use in Map.
function Star_Trek.LCARS:OpenTransporterMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "transporter")
end
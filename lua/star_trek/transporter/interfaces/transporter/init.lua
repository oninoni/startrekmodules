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
--     LCARS Transporter | Server    --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

include("util.lua")
include("windowUtil.lua")

SELF.BaseInterface = "base"

SELF.LogType = "Transporter Console"

SELF.Solid = true

SELF.CycleClass = "federation"

SELF.AdvancedMode = true

function SELF:OpenInternal(menuTable, mainTable, sliderTable, textTable)
	local menuPosSource = menuTable.Pos + Vector()
	local menuPosTarget = menuTable.Pos + Vector()
	menuPosTarget[1] = -menuPosTarget[1]

	local menuAngleSource = menuTable.Ang + Angle()
	local menuAngleTarget = menuTable.Ang + Angle()
	menuAngleTarget[1] = -menuAngleTarget[1]
	menuAngleTarget[2] = -menuAngleTarget[2]

	local mainPosSource = mainTable.Pos + Vector()
	local mainPosTarget = mainTable.Pos + Vector()
	mainPosTarget[1] = -mainPosTarget[1]

	local mainAngleSource = mainTable.Ang + Angle()
	local mainAngleTarget = mainTable.Ang + Angle()
	mainAngleTarget[1] = -mainAngleTarget[1]
	mainAngleTarget[2] = -mainAngleTarget[2]

	local sourceSuccess, sourceMenuTable = self:CreateWindowTable(
		menuPosSource, menuAngleSource, menuTable.Width,
		mainPosSource, mainAngleSource, mainTable.Width, mainTable.Height,
		false, false
	)
	if not sourceSuccess then
		return false, sourceMenuTable
	end

	local targetSuccess, targetMenuTable = self:CreateWindowTable(
		menuPosTarget, menuAngleTarget, menuTable.Width,
		mainPosTarget, mainAngleTarget, mainTable.Width, mainTable.Height,
		true , true
	)
	if not targetSuccess then
		return false, targetMenuTable
	end

	-- For Reference
	sourceMenuTable.TargetMenuTable = targetMenuTable
	targetMenuTable.SourceMenuTable = sourceMenuTable

	local textSuccess, textWindow
	if istable(textTable) then
		textSuccess, textWindow = Star_Trek.LCARS:CreateWindow(
			"log_entry",
			textTable.Pos,
			textTable.Ang,
			24,
			textTable.Width,
			textTable.Height,
			function(windowData, interfaceData, ply, categoryId, buttonId)
				return false
			end
		)
		if not textSuccess then
			return false, textWindow
		end
	end

	local sliderSuccess, sliderWindow = Star_Trek.LCARS:CreateWindow(
		"transport_slider",
		sliderTable.Pos,
		sliderTable.Ang,
		30,
		200,
		200,
		function(windowData, interfaceData, ply, buttonId)
			self:TriggerTransporter(ply, sourceMenuTable, targetMenuTable)
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

	self.PadEntities = {}
	for _, padEntity in pairs(ents.GetAll()) do
		local name = padEntity:GetName()

		if string.StartWith(name, "TRPad") then
			local values = string.Split(string.sub(name, 6), "_")
			local n = tonumber(values[2])

			if n ~= padNumber then continue end

			table.insert(self.PadEntities, padEntity)
		end
	end

	local success, windows = self:OpenInternal(
		{
			Pos = Vector(-13, 0, 6),
			Ang = Angle(20, 0, -20),
			Width = 350,
		},
		{
			Pos = Vector(-30, 4, 19),
			Ang = Angle(55, 0, -20),
			Width = 500, Height = 500,
		},
		{
			Pos = Vector(0, -4, -0.5),
			Ang = Angle(0, 0, -68),
		},
		{
			Pos = Vector(22, 24.5, 126.5),
			Ang = Angle(192, 0, 0),
			Width = 670, Height = 640,
		}
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
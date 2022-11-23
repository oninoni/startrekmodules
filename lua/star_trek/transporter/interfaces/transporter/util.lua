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
--      LCARS Transporter | Util     --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

local DEMAT_DELAY = 5

function SELF:GetSelectedMenuType(menuTable)
	local selected = menuTable.MenuWindow:GetSelected()

	local menuType
	for type, active in pairs(selected) do
		if active then
			menuType = type
		end
	end

	return menuType
end

function SELF:GetMenuType(menuType, target)
	if istable(menuType) then
		if target then
			menuType = menuType[2]
		else
			menuType = menuType[1]
		end
	end

	return menuType
end

-- Returns the name of the currently selected transporter mode.
--
-- @param Table menuTable
-- @return String modeName
function SELF:GetMode(menuTable)
	local menuType = self:GetSelectedMenuType(menuTable)
	local modeName = self:GetMenuType(menuType, menuTable.Target)

	return modeName
end

-- Scan the selected menuTable for entities and compile locations for a beamin.
--
-- @param table menuTable
-- @param Boolean wideField
-- @return table patterns
function SELF:GetPatternData(menuTable, wideField)
	local modeName = self:GetMode(menuTable)
	local mainWindow = menuTable.MainWindow

	-- Transporter Pad: 			Table Wrapped Pad Entity
	-- Transporter Rooms: 			Table Wrapped Pad Entity
	-- Crew: 						Entities
	-- Buffer: 						Entities (Force wideField = False)
	-- Externals: 					Vectors
	-- Sections: 					Tables (Deck + SectionId)
	-- Custom: 						Callback Functions

	local patternObjects = {}
	if modeName == "Transporter Pad" then
		for _, pad in pairs(mainWindow.Pads) do
			if pad.Selected then
				local padTable = {Pad = pad.Data}
				table.insert(patternObjects, padTable)
			end
		end
	elseif modeName == "Transporter Rooms"  then
		for _, button in pairs(mainWindow.Buttons) do
			if button.Selected then
				for _, padEntity in pairs(button.Data) do
					local padTable = {Pad = padEntity}
					table.insert(patternObjects, padTable)
				end
			end
		end
	elseif modeName == "Crew" then
		for _, button in pairs(mainWindow.Buttons) do
			if button.Selected then
				table.insert(patternObjects, button.Data)
			end
		end
	elseif modeName == "Buffer" then
		wideField = false -- Forcing WideField False, to only ever take one person out of buffer.

		for _, button in pairs(mainWindow.Buttons) do
			if button.Selected then
				table.insert(patternObjects, button.Data)
			end
		end
	elseif modeName == "Sections" then
		local patternObject = {
			Deck = mainWindow.Selected,
			SectionIds = {}
		}

		for buttonId, buttonData in pairs(mainWindow.Buttons) do
			if buttonData.Selected then
				table.insert(patternObject.SectionIds, buttonData.Data)
			end
		end

		table.insert(patternObjects, patternObject)
	elseif modeName == "External Sensors" then
		for _, button in pairs(mainWindow.Buttons) do
			if button.Selected then
				local pos = button.Data
				table.insert(patternObjects, pos)
			end
		end
	end

	return Star_Trek.Transporter:GetPatterns(patternObjects, menuTable.Target, wideField)
end

-- Prevent Noclipped players from being listed.
hook.Add("Star_Trek.Transporter.CheckLifeforms", "Star_Trek.Transporter.PreventAdmins", function(ply)
	if ply:GetMoveType() == MOVETYPE_NOCLIP and not ply:GetParent():IsVehicle() then
		return false
	end
end)

-- Engage a transporter system with the given menu tables and wide field.
--
-- @param Player ply
-- @param Table sourceMenuTable
-- @param Table targetMenuTable
-- @param? Boolean wideField
-- @param? Function callback
function SELF:Energize(ply, sourceMenuTable, targetMenuTable, wideField, allowWeapons ,callback)
	local sourcePatterns = self:GetPatternData(sourceMenuTable, wideField)
	local targetPatterns = self:GetPatternData(targetMenuTable, false)
	Star_Trek.Transporter:ActivateTransporter(self.Ent, ply, sourcePatterns, targetPatterns, self.CycleClass, self.NoBuffer, allowWeapons)

	if isfunction(callback) then
		callback(sourcePatterns, targetPatterns)
	end
end

-- Force Update of Source Buffer Table, by just switching.
--
-- @param Table sourceMenuTable
function SELF:UpdateBufferMenu(sourceMenuTable)
	local success, error = sourceMenuTable:SelectType(sourceMenuTable.MenuTypes[1])
	if not success then
		Star_Trek:Message(error)
		return
	end

	sourceMenuTable.MenuWindow:Update()
	sourceMenuTable.MainWindow:Update()
end

-- Trigger a Transporter.
--
-- @param Player ply
-- @param Table sourceMenuTable
-- @param Table targetMenuTable
function SELF:TriggerTransporter(ply, sourceMenuTable, targetMenuTable)
	local wideField = false
	if isfunction(sourceMenuTable.GetUtilButtonState) then
		wideField = sourceMenuTable:GetUtilButtonState()
	end

	local delayDematerialisation = false
	if isfunction(targetMenuTable.GetUtilButtonState) then
		delayDematerialisation = targetMenuTable:GetUtilButtonState()
	end

	local allowWeapons = true 
	if isfunction(targetMenuTable.GetWeaponsButtonState) then
		allowWeapons = targetMenuTable:GetWeaponsButtonState()
	end

	if delayDematerialisation then
		timer.Simple(DEMAT_DELAY, function()
			self:Energize(ply, sourceMenuTable, targetMenuTable, wideField, allowWeapons, function(sourcePatterns, targetPatterns)
				if sourcePatterns.IsBuffer then self:UpdateBufferMenu(sourceMenuTable) end
			end)
		end)
	else
		self:Energize(ply, sourceMenuTable, targetMenuTable, wideField, allowWeapons ,function(sourcePatterns, targetPatterns)
			if sourcePatterns.IsBuffer then self:UpdateBufferMenu(sourceMenuTable) end
		end)
	end
end
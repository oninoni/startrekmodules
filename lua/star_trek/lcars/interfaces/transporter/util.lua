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
--      LCARS Transporter | Util     --
---------------------------------------

local transporterUtil = {}

local DEMAT_DELAY = 5

function transporterUtil.GetMenuType(menuType, target)
	if istable(menuType) then
		if target then
			menuType = menuType[2]
		else
			menuType = menuType[1]
		end
	end

	return menuType
end

function transporterUtil.GetSelectedMenuType(menuTable)
	local selected = menuTable.MenuWindow:GetSelected()

	local menuType
	for type, active in pairs(selected) do
		if active then
			menuType = type
		end
	end

	return menuType
end

-- Returns the name of the currently selected transporter mode.
--
-- @param Table menuTable
-- @return String modeName
function transporterUtil.GetMode(menuTable)
	local menuType = transporterUtil.GetSelectedMenuType(menuTable)
	local modeName = transporterUtil.GetMenuType(menuType, menuTable.Target)

	return modeName
end

-- Scan the selected menuTable for entities and compile locations for a beamin.
--
-- @param table menuTable
-- @param Boolean wideField
-- @return table patterns
function transporterUtil.GetPatternData(menuTable, wideField)
	local modeName = transporterUtil.GetMode(menuTable)
	local mainWindow = menuTable.MainWindow

	if modeName == "Transporter Pad" then
		local pads = {}
		for _, pad in pairs(mainWindow.Pads) do
			if pad.Selected then
				table.insert(pads, pad.Data)
			end
		end

		return Star_Trek.Transporter:GetPatternsFromPads(pads)
	elseif modeName == "Lifeforms" then
		local players = {}
		for _, button in pairs(mainWindow.Buttons) do
			if button.Selected then
				table.insert(players, button.Data)
			end
		end

		return Star_Trek.Transporter:GetPatternsFromPlayers(players, wideField)
	elseif modeName == "Sections" then
		local positions = {}

		if menuTable.Target then
			local categoryData = mainWindow.Categories[mainWindow.Selected]
			for _, button in pairs(categoryData.Buttons or {}) do
				if button.Selected then
					local sectionData = button.Data or {}

					for _, pos in pairs(sectionData.BeamLocations or {}) do
						table.insert(positions, pos)
					end
				end
			end

			return Star_Trek.Transporter:GetPatternsFromLocations(positions, wideField)
		else
			local deck = mainWindow.Selected
			local categoryData = mainWindow.Categories[deck]

			local sectionIds = {}

			for buttonId, buttonData in pairs(categoryData.Buttons) do
				if buttonData.Selected then
					table.insert(sectionIds, buttonData.Data)
				end
			end

			return Star_Trek.Transporter:GetPatternsFromAreas(deck, sectionIds)
		end
	elseif modeName == "Buffer" then
		local entities = {}
		for _, button in pairs(mainWindow.Buttons) do
			if button.Selected then
				table.insert(entities, button.Data)
			end
		end

		return Star_Trek.Transporter:GetPatternsFromBuffers(entities)
	elseif modeName == "Other Pads" or modeName == "Transporter Pads"  then
		local pads = {}
		for _, button in pairs(mainWindow.Buttons) do
			if button.Selected then
				for _, pad in pairs(button.Data) do
					table.insert(pads, pad)
				end
			end
		end

		return Star_Trek.Transporter:GetPatternsFromPads(pads)
	end
end

-- Engage a transporter system with the given menu tables and wide field.
--
-- @param Table sourceMenuTable
-- @param Table targetMenuTable
-- @param? Boolean wideField
-- @param? Function callback
function transporterUtil.Energize(sourceMenuTable, targetMenuTable, wideField, callback)
	local sourcePatterns = transporterUtil.GetPatternData(sourceMenuTable, wideField)
	local targetPatterns = transporterUtil.GetPatternData(targetMenuTable, false)
	Star_Trek.Transporter:ActivateTransporter(sourcePatterns, targetPatterns)

	if isfunction(callback) then
		callback(sourcePatterns, targetPatterns)
	end
end

-- Force Update of Source Buffer Table, by just switching.
--
-- @param Table interfaceData
function transporterUtil.UpdateBufferMenu(interfaceData)
	local sourceMenuTable = interfaceData.SourceMenuTable

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
-- @param Table interfaceData
function transporterUtil.TriggerTransporter(interfaceData)
	local sourceMenuTable = interfaceData.SourceMenuTable
	local targetMenuTable = interfaceData.TargetMenuTable

	local wideField = false
	if isfunction(sourceMenuTable.GetUtilButtonState) then
		wideField = sourceMenuTable:GetUtilButtonState()
	end

	local delayDematerialisation = false
	if isfunction(targetMenuTable.GetUtilButtonState) then
		delayDematerialisation = targetMenuTable:GetUtilButtonState()
	end

	if delayDematerialisation then
		timer.Simple(DEMAT_DELAY, function()
			transporterUtil.Energize(sourceMenuTable, targetMenuTable, wideField, function(sourcePatterns, targetPatterns)
				if sourcePatterns.IsBuffer then transporterUtil.UpdateBufferMenu(interfaceData) end
			end)
		end)
	else
		transporterUtil.Energize(sourceMenuTable, targetMenuTable, wideField, function(sourcePatterns, targetPatterns)
			if sourcePatterns.IsBuffer then transporterUtil.UpdateBufferMenu(interfaceData) end
		end)
	end
end

return transporterUtil
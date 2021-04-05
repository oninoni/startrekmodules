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

function transporterUtil.GetSelectionName(menuTable)
	local selection = menuTable.MenuWindow.Selection
	local selectionName = menuTable.MenuTypes[selection]
	if istable(selectionName) then
		if menuTable.Target then
			selectionName = selectionName[2]
		else
			selectionName = selectionName[1]
		end
	end

	return selectionName
end

function transporterUtil.GetPatternData(menuTable, wideField)
	local selectionName = transporterUtil.GetSelectionName(menuTable)
	local mainWindow = menuTable.MainWindow

	if selectionName == "Transporter Pad" then
		local pads = {}
		for _, pad in pairs(mainWindow.Pads) do
			if pad.Selected then
				table.insert(pads, pad.Data)
			end
		end

		return Star_Trek.Transporter:GetPatternsFromPads(pads)
	elseif selectionName == "Lifeforms" then
		local players = {}
		for _, button in pairs(mainWindow.Buttons) do
			if button.Selected then
				table.insert(players, button.Data)
			end
		end

		return Star_Trek.Transporter:GetPatternsFromPlayers(players, wideField)
	elseif selectionName == "Sections" then
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
					table.insert(sectionIds, buttonData.Data.Id)
				end
			end

			return Star_Trek.Transporter:GetPatternsFromAreas(deck, sectionIds)
		end
	elseif selectionName == "Buffer" then
		local entities = {}
		for _, button in pairs(mainWindow.Buttons) do
			if button.Selected then
				table.insert(entities, button.Data)
			end
		end

		return Star_Trek.Transporter:GetPatternsFromBuffers(entities)
	elseif selectionName == "Other Pads" or selectionName == "Transporter Pads"  then
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

function transporterUtil.Energize(sourcePatterns, targetPatterns, callback)
	Star_Trek.Transporter:ActivateTransporter(sourcePatterns, targetPatterns)

	if isfunction(callback) then
		callback()
	end
end

-- Force Update of Buffer Table, by just switching.
-- Updating would require a callback (TODO)
function transporterUtil.UpdateBufferMenu(interfaceData)
	local sourceMenuTable = interfaceData.SourceMenuTable

	local success, error = sourceMenuTable:SelectType(1)
	if not success then
		Star_Trek:Message(error)
		return
	end

	local ent = table.KeyFromValue(Star_Trek.LCARS.ActiveInterfaces, interfaceData)
	if not IsValid(ent) then
		Star_Trek:Message("Invalid Entity on Buffer Menu Update")
		return
	end

	Star_Trek.LCARS:UpdateWindow(ent, sourceMenuTable.MenuWindow.Id, sourceMenuTable.MenuWindow)
	Star_Trek.LCARS:UpdateWindow(ent, sourceMenuTable.MainWindow.Id, sourceMenuTable.MainWindow)
end

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
		timer.Simple(5, function()
			local sourcePatterns = transporterUtil.GetPatternData(sourceMenuTable, wideField)
			local targetPatterns = transporterUtil.GetPatternData(targetMenuTable, false)

			transporterUtil.Energize(sourcePatterns, targetPatterns, function()
				if sourcePatterns.IsBuffer then transporterUtil.UpdateBufferMenu(interfaceData) end
			end)
		end)
	else
		local sourcePatterns = transporterUtil.GetPatternData(sourceMenuTable, wideField)
		local targetPatterns = transporterUtil.GetPatternData(targetMenuTable, false)

		transporterUtil.Energize(sourcePatterns, targetPatterns, function()
			if sourcePatterns.IsBuffer then transporterUtil.UpdateBufferMenu(interfaceData) end
		end)
	end
end

return transporterUtil
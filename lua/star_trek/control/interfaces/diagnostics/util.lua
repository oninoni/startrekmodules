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
--     LCARS Disagnostics | Util     --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

local MODE_DIAGNOSTICS = 1
local MODE_CONTROL = 2

function SELF:GetModeButtons(mode)
	mode = mode or MODE_SCAN

	local actions = {}
	local actionColors = {}
	if mode == MODE_DIAGNOSTICS then
		actions = {
			[1] = "Start Sections Diagnostic",
			[2] = "Start Deck Diagnostic",

			[6] = "Start Ship Diagnostic",
		}
		actionColors = {
			[6] = Star_Trek.LCARS.ColorOrange,
		}
	elseif mode == MODE_CONTROL then
		actions = {
			[1] = "Toggle Sections Status",
			[2] = "Toggle Deck Status",
			[3] = "Toggle Ship Status",

			[6] = "Select Control Mode",
		}
		actionColors = {
			[6] = Star_Trek.LCARS.ColorOrange,
		}
	end

	local buttons = {}
	for i, name in pairs(actions) do
		local color = actionColors[i]
		if not color then
			if i % 2 == 0 then
				color = Star_Trek.LCARS.ColorLightBlue
			else
				color = Star_Trek.LCARS.ColorBlue
			end
		end

		buttons[i] = {
			Name = name,
			Color = color,
			Disabled = mode == MODE_CONTROL,
		}
	end

	return buttons
end

function SELF:StartDiagnostics(ply, deck, sectionIds)
	for name, controlType in pairs(Star_Trek.Control.Types) do
		local realName = controlType.RealName

		local shipValue = controlType.Value
		if shipValue == Star_Trek.Control.INACTIVE then
			Star_Trek.Logs:AddEntry(self.Ent, ply, realName .. " are deactivated on the entire ship.")
			continue
		elseif shipValue == Star_Trek.Control.INOPERATIVE then
			Star_Trek.Logs:AddEntry(self.Ent, ply, realName .. " are inoperative on the entire ship.")
			continue
		end

		for controlDeck, deckData in pairs(controlType) do
			if not isnumber(controlDeck) then continue end
			if isnumber(deck) and controlDeck ~= deck then continue end

			local deckValue = deckData.Value
			if deckValue == Star_Trek.Control.INACTIVE then
				Star_Trek.Logs:AddEntry(self.Ent, ply, realName .. " are deactivated on Deck " .. controlDeck .. ".")
				continue
			elseif deckValue == Star_Trek.Control.INOPERATIVE then
				Star_Trek.Logs:AddEntry(self.Ent, ply, realName .. " are inoperative on Deck " .. controlDeck .. ".")
				continue
			end

			for controlSectionId, sectionValue in pairs(deckData) do
				if not isnumber(controlSectionId) then continue end
				if istable(sectionIds) and not table.HasValue(sectionIds, controlSectionId) then continue end

				local sectionName, _ = Star_Trek.Sections:GetSectionName(controlDeck, controlSectionId)

				if sectionValue == Star_Trek.Control.INACTIVE then
					Star_Trek.Logs:AddEntry(self.Ent, ply, realName .. " are deactivated on Deck " .. controlDeck .. " " .. sectionName .. ".")
					continue
				elseif sectionValue == Star_Trek.Control.INOPERATIVE then
					Star_Trek.Logs:AddEntry(self.Ent, ply, realName .. " are inoperative on Deck " .. controlDeck .. " " .. sectionName .. ".")
					continue
				end
			end
		end
	end
end

function SELF:ActionButtonPressed(windowData, ply, buttonId, buttonData)
	local buttonName = buttonData.Name
	local sectionWindow = self.Windows[2]
	--local mapWindow = self.Windows[3]

	local deck = sectionWindow.Selected
	local sectionIds = {}
	for _, sectionButtonData in pairs(sectionWindow.Buttons) do
		if sectionButtonData.Selected then
			table.insert(sectionIds, sectionButtonData.Data)
		end
	end

	if windowData.Mode == MODE_DIAGNOSTICS then
		Star_Trek.Logs:AddEntry(self.Ent, ply, "")
		Star_Trek.Logs:AddEntry(self.Ent, ply, "Starting system diagnostic!")

		if buttonName == "Start Sections Diagnostic" then
			Star_Trek.Logs:AddEntry(self.Ent, ply, "Diagnosing systems in Sections on Deck " .. deck .. "!")
			Star_Trek.Logs:AddEntry(self.Ent, ply, "")

			self:StartDiagnostics(ply, deck, sectionIds)
		elseif buttonName == "Start Deck Diagnostic" then
			Star_Trek.Logs:AddEntry(self.Ent, ply, "Diagnosing systems on Deck " .. deck .. "!")
			Star_Trek.Logs:AddEntry(self.Ent, ply, "")

			self:StartDiagnostics(ply, deck)
		elseif buttonName == "Start Ship Diagnostic" then
			Star_Trek.Logs:AddEntry(self.Ent, ply, "Diagnosing systems on all decks!")
			Star_Trek.Logs:AddEntry(self.Ent, ply, "")

			self:StartDiagnostics(ply)
		end

		Star_Trek.Logs:AddEntry(self.Ent, ply, "System diagnostic concluded!")

		return true
	elseif windowData.Mode == MODE_CONTROL then
		if buttonName == "Toggle Sections Status" then

		elseif buttonName == "Toggle Deck Status" then
			
		elseif buttonName == "Toggle Ship Status" then
			
		elseif buttonName == "Select Control Mode" then

		end

		return true
	end
end
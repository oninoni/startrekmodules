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
--       LCARS Turbolift | Util      --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

function SELF:GenerateButtons(ent, keyValues)
	local buttons = {}

	local name = ""
	if ent.IsTurbolift then
		name = keyValues["lcars_name"]
	elseif ent.IsPod then
		local podData = ent.Data

		local controlButton = {}
		if podData.Stopped or podData.TravelTarget == nil then
			controlButton.Name = "Resume Lift"
		else
			controlButton.Name = "Stop Lift"
		end
		controlButton.Color = Star_Trek.LCARS.ColorRed

		buttons[1] = controlButton
	end

	for i, turboliftData in SortedPairs(Star_Trek.Turbolift.Lifts) do
		local button = {
			Name = turboliftData.Name,
			Disabled = turboliftData.Name == name,
		}

		buttons[#buttons + 1] = button
	end

	return buttons
end
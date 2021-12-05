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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--       LCARS Turbolift | Util      --
---------------------------------------

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
		controlButton.Color = Star_Trek.LCARS.ColorLightRed

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
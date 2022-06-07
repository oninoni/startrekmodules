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

function SELF:GenerateButtons(ent, name)
	local buttons = {}

	local data = ent.Data
	local shipId = data.ShipId

	if ent.IsPod then
		local controlButton = {}
		if data.Stopped or data.TravelTarget == nil then
			controlButton.Name = "Resume Lift"
		else
			controlButton.Name = "Stop Lift"
		end
		controlButton.Color = Star_Trek.LCARS.ColorRed

		buttons[1] = controlButton
	end

	for i, turboliftData in SortedPairs(Star_Trek.Turbolift.Lifts) do
		if shipId ~= turboliftData.ShipId then
			continue
		end

		local button = {
			Name = turboliftData.Name,
			Disabled = turboliftData.Name == name,
		}

		buttons[#buttons + 1] = button
	end

	return buttons
end
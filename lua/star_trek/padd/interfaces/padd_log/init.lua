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
--      LCARS PADD Logs | Server     --
---------------------------------------

local SELF = INTERFACE
SELF.BaseInterface = "base"

function SELF:Open(ent)
	local success, window = Star_Trek.LCARS:CreateWindow(
		"text_entry",
		Vector(),
		Angle(),
		ent.MenuScale or 35,
		ent.MenuWidth or 325,
		ent.MenuHeight or 540,
		function(windowData, interfaceData, buttonId)

		end,
		Color(255, 255, 255),
		"Logs",
		"LOGS",
		false
	)
	if not success then
		return false, window
	end

	return true, {window}
end

function SELF:SetData(logType, lines)
	local window = self.Windows[1]
	if istable(window) then
		window.Title = logType
		window.Lines = lines

		window:Update()
	end
end
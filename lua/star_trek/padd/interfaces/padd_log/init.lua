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
--      LCARS PADD Logs | Server     --
---------------------------------------

local SELF = INTERFACE
SELF.BaseInterface = "base"

function SELF:Open(ent, title, lines)
	local success, window = Star_Trek.LCARS:CreateWindow(
		"text_entry",
		Vector(),
		Angle(),
		ent.MenuScale,
		ent.MenuWidth,
		ent.MenuHeight,
		function(windowData, interfaceData, buttonId)

		end,
		Color(255, 255, 255),
		title or "Logs",
		"LOGS",
		false,
		lines
	)
	if not success then
		return false, window
	end

	return true, {window}
end

function SELF:SetData(logType, lines)
	local window = self.Windows[1]
	window.Title = logType
	window.Lines = lines

	window:Update()
end

function SELF:GetData()
	local window = self.Windows[1]
	return window.Title, window.Lines
end
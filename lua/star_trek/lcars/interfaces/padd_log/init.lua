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

function SELF:Open(ent, logType, lines)
	local success, window = Star_Trek.LCARS:CreateWindow(
		"text_entry",
		Vector(),
		Angle(),
		35,
		325,
		540,
		function(windowData, interfaceData, buttonId)

		end,
		Color(255, 255, 255),
		logType .. " Logs",
		"LOGS",
		false,
		lines
	)
	if not success then
		return false, window
	end

	return true, {window}
end
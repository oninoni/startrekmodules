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
--    LCARS OPS Interface | Server   --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = "bridge_targeting_base"

-- Opening general purpose menus.
function SELF:Open(ent)
	local success, windows, offsetPos, offsetAngle = SELF.Base.Open(self, ent, false)

	local scannerSelectionWindowPos = Vector(0, -1.5, 3.3)
	local scannerSelectionWindowAng = Angle(0, 0, 11)

	local success2, scannerWindow = Star_Trek.LCARS:CreateWindow("button_matrix", scannerSelectionWindowPos, scannerSelectionWindowAng, nil, 380, 320,
	function(windowData, interfaceData, ply, categoryId, buttonId)
		-- No Interactivity here yet.
	end, "Scanner Control", "SCANNER", not self.Flipped)
	if not success2 then
		return false, scannerWindow
	end
	table.insert(windows, scannerWindow)

	local logSelectionWindowPos = Vector(26, -1, 3.5)
	local logSelectionWindowAng = Angle(0, 0, 11)

	local success3, logWindow = Star_Trek.LCARS:CreateWindow("log_entry", logSelectionWindowPos, logSelectionWindowAng, nil, 360, 350,
	function(windowData, interfaceData, ply, categoryId, buttonId)
		-- No Interactivity here yet.
	end)
	if not success3 then
		return false, logWindow
	end
	table.insert(windows, logWindow)

	return success, windows, offsetPos, offsetAngle
end
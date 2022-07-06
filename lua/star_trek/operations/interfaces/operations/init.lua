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

	return success, windows, offsetPos, offsetAngle
end
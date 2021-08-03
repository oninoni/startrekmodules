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
--    LCARS Engi Security | Server   --
---------------------------------------

local SELF = INTERFACE
SELF.BaseInterface = "bridge_security"

-- Wrap for use in Map.
function Star_Trek.LCARS:OpenSecurityEngMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "eng_security", true)
end
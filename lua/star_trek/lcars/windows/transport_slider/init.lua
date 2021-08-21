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
--  LCARS Transport Slider | Server  --
---------------------------------------

local SELF = WINDOW
function SELF:OnPress(interfaceData, ent, buttonId, callback)
	callback(windowData, interfaceData, buttonId)
end
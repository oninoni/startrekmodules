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
--  LCARS Transport Slider | Server  --
---------------------------------------

local SELF = WINDOW
function WINDOW:OnPress(interfaceData, ent, buttonId, callback)
	ent:EmitSound("star_trek.lcars_transporter_lock")

	callback(windowData, interfaceData, buttonId)
end
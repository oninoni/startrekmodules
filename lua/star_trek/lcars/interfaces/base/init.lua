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
--   LCARS Base Interface | Server   --
---------------------------------------

local SELF = INTERFACE

-- Opens the Interface. Must return the windows in a table. -- TODO: Remove the return?
-- 
-- @return Table windows
function SELF:Open()
	return {}
end

-- Updates a given Window.
function SELF:UpdateWindow(windowId, windowData)
	Star_Trek.LCARS:UpdateWindow(self.Ent, windowId, windowData)
end

-- Closes the Interface.
function SELF:Close()
	Star_Trek.LCARS:CloseInterface(self.Ent)
end

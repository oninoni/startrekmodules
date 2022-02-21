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
--   LCARS Base Interface | Server   --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = nil

SELF.LogType = "LCARS Interface"

-- Opens the Interface. Must return the windows in a table.
-- 
-- @param Entity ent
-- @return Boolean success
-- @return? Table windows
function SELF:Open(ent)
	return false, "Do not use the Base Interface."
end

-- Updates a given Window.
--
-- @param Number windowId
-- @param Table windowData
function SELF:UpdateWindow(windowId, windowData)
	Star_Trek.LCARS:UpdateWindow(self.Ent, windowId, windowData)
end

-- Closes the Interface.
function SELF:Close(callback)
	self.Ent:EmitSound("star_trek.lcars_close")
	Star_Trek.LCARS:CloseInterface(self.Ent, callback)
end

-- Read out any Data, that can be retrieved externally.
--
-- @return? Table data
function SELF:GetData()
	return false
end
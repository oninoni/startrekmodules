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
--    LCARS Button Element | Util    --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

-- Returns the 2digit LCARS Number as a string.
--
-- @param? Number value
-- @return String smallNumber
function SELF:ConvertNumber(value)
	if not value then
		return false
	end

	if value < 10 then
		return "0" .. tostring(value)
	else
		return tostring(value)
	end
end
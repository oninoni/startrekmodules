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
function SELF:ConvertSmallNumber(value)
	if value < 10 then
		return "0" .. tostring(value)
	else
		return tostring(value)
	end
end

-- Returns the 6digit LCARS Number as a string.
--
-- @param? Number value
-- @return String largeNumber
function SELF:ConvertLargeNumber(value)
	local largeNumber = ""

	if value < 10 then
		largeNumber = "00000" .. tostring(value)
	elseif value < 100 then
		largeNumber = "0000" .. tostring(value)
	elseif value < 1000 then
		largeNumber = "000" .. tostring(value)
	elseif value < 10000 then
		largeNumber = "00" .. tostring(value)
	elseif value < 100000 then
		largeNumber = "0" .. tostring(value)
	else
		largeNumber = tostring(value)
	end

	return string.sub(largeNumber, 1, 2) .. "-" .. string.sub(largeNumber, 3)
end
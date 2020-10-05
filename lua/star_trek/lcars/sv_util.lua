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
--        LCARS Util | Server        --
---------------------------------------

-- Returns the 2digit LCARS Number as a string.
--
-- @param? Number value
-- @return String smallNumber
function Star_Trek.LCARS:GetSmallNumber(value)
    if not (isnumber(value) and value >= 0 and value < 100) then
        value = math.random(0, 99)
    end

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
function Star_Trek.LCARS:GetLargeNumber(value)
    if not (isnumber(value) and value >= 0 and value < 1000000) then
        value = math.random(0, 999999)
    end

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
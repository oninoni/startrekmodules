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
--    Frame Double Element | Util    --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

-- Draw the swept for LCARS frames.
--
-- @param Number x
-- @param Number y
-- @param Number width
-- @param Color color1
-- @param Color color2
-- @param? Boolean hFlip
-- @param? Number holeSize
function SELF:DrawSweptBreak(x, y, width, color1, color2, hFlip, holeSize)
	self:DrawSwept(x, y											  , width, color1, hFlip, false, holeSize)
	self:DrawSwept(x, y + 2 * self.CornerRadius + self.FrameOffset, width, color2, hFlip, true, 		0)
end
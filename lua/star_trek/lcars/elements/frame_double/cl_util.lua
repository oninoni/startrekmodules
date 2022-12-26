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

function SELF:DrawSweptTitle(x, y, width, title, hFlip)
	if hFlip == WINDOW_BORDER_LEFT then
		draw.SimpleText(string.upper(title), "LCARSMed", x + width - 8, y + 2, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	elseif hFlip == WINDOW_BORDER_RIGHT then
		draw.SimpleText(string.upper(title), "LCARSMed", x +         8, y + 2, nil, TEXT_ALIGN_LEFT,  TEXT_ALIGN_TOP)
	elseif hFlip == WINDOW_BORDER_BOTH then
		draw.SimpleText(string.upper(title), "LCARSMed", x + width / 2, y + 2, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end

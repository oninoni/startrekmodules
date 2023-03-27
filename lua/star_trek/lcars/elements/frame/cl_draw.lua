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
--     LCARS Frame Element | Draw    --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

-- Draw a single frame for an LCARS interface.
--
-- @param Number x
-- @param Number y
-- @param Number width
-- @param Number height
-- @param Color color1
-- @param Color color2
-- @param String title
-- @param String titleShort
-- @param? Boolean hFlip
function SELF:DrawFrame(x, y, width, height, color1, color2, title, titleShort, hFlip)
	self:DrawSwept(x, y                                 , width, color1, hFlip,  true, textWidth)
	self:DrawSwept(x, y + height - self.CornerRadius * 2, width, color2, hFlip, false)

	local frameStartOffset = self.CornerRadius * 2
	self:DrawSweptSide(x, y, width, height - frameStartOffset, color1, color2, titleShort, hFlip, frameStartOffset)
	if hFlip == WINDOW_BORDER_BOTH then
		self:DrawSweptSide(x, y, width, height - frameStartOffset, color1, color2, titleShort, false, frameStartOffset)
	end
end
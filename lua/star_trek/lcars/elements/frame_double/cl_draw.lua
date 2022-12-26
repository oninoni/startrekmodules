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
--    Frame Double Element | Draw    --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

-- Draw a double frame for an LCARS interface.
--
-- @param Number x
-- @param Number y
-- @param Number width
-- @param Number height
-- @param Color color1
-- @param Color color2
-- @param Color color3
-- @param String title
-- @param String titleShort
-- @param? Boolean hFlip
function SELF:DrawDoubleFrame(x, y, width, height, color1, color2, color3, title, titleShort, hFlip)
	self:DrawSweptTitle(x, y, width, title, hFlip)

	self:DrawSweptBreak(x, y, width, color1, color2, hFlip)

	local frameStartOffset = self.CornerRadius * 4 + self.FrameOffset
	self:DrawSweptSide(x, y, width, height, color2, color3, titleShort, hFlip, frameStartOffset)
	if hFlip == WINDOW_BORDER_BOTH then
		self:DrawSweptSide(x, y, width, height, color2, color3, titleShort, false, frameStartOffset)
	end
end
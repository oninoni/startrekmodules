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
--    Frame Triple Element | Draw    --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

-- Draw a triple frame for an LCARS interface.
--
-- @param Number x
-- @param Number y
-- @param Number width
-- @param Number height
-- @param Number height2
-- @param Color color1
-- @param Color color2
-- @param Color color3
-- @param Color color4
-- @param String title
-- @param String titleShort
-- @param? Boolean hFlip
function SELF:DrawTripleFrame(x, y, width, height, height2, color1, color2, color3, color4, title, titleShort, hFlip)
	self:DrawSweptTitle(x, y, width, title, hFlip)

	self:DrawSweptBreak(x,       y, width, color1, color2, hFlip)
	self:DrawSweptBreak(x, y + height2, width, color2, color3, hFlip)

	local topFrameStartOffset = self.CornerRadius * 4 + self.FrameOffset
	self:DrawSweptSide(x, y, width, height2, color2, nil, titleShort, hFlip, topFrameStartOffset)
	if hFlip == WINDOW_BORDER_BOTH then
		self:DrawSweptSide(x, y, width, height2, color2, nil, titleShort, false, topFrameStartOffset)
	end

	local secondFrameStartOffset = height2 + topFrameStartOffset
	self:DrawSweptSide(x, y, width, height, color3, color4, nil, hFlip, secondFrameStartOffset)
	if hFlip == WINDOW_BORDER_BOTH then
		self:DrawSweptSide(x, y, width, height, color3, color4, nil, false, secondFrameStartOffset)
	end
end
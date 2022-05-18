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
--    LCARS Button Matrix | Client   --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(windowData)
	self.Padding = self.Padding or 1
	self.FrameType = self.FrameType or "frame_double"

	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	return true
end

function SELF:OnPress(pos, animPos)
	
end

function SELF:OnDraw(pos, animPos)


	SELF.Base.OnDraw(self, pos, animPos)
end
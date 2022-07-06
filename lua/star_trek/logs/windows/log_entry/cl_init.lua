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
--      LCARS Log Entry | Client     --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(windowData)
	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	return true
end

function SELF:OnPress(pos, animPos)
	return SELF.Base.OnPress(self, pos, animPos)
end

function SELF:OnDraw(pos, animPos)
	SELF.Base.OnDraw(self, pos, animPos)
end
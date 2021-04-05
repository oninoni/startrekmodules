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
--     LCARS Base Window | Client    --
---------------------------------------

local SELF = WINDOW
function SELF:OnCreate()
	return true
end

function SELF:GetSelected()
	return {}
end

function SELF:SetSelected(data)
end

function SELF:Update()
	Star_Trek.LCARS:UpdateWindow(self.Ent, self.Id)
end

function SELF:OnPress(interfaceData, ent, buttonId, callback)
	callback(windowData, interfaceData, buttonId)
end
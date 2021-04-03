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
function WINDOW:OnCreate()
	return true
end

function WINDOW:GetSelected()
    return {}
end

function WINDOW:SetSelected(data)
end

function WINDOW:Update()
	Star_Trek.LCARS:UpdateWindow(self.Ent, self.Id, self)
end

function WINDOW:OnPress(interfaceData, ent, buttonId, callback)
	callback(windowData, interfaceData, ent, buttonId)
end
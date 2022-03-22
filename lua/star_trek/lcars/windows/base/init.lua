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
--     LCARS Base Window | Client    --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate()
	return true
end

function SELF:GetClientData()
	local clientData = {
		WType = self.WindowType,

		WPos = self.WindowPos,
		WAng = self.WindowAngles,

		WScale = self.WindowScale,
		WWidth = self.WindowWidth,
		WHeight = self.WindowHeight,
	}

	return clientData
end

function SELF:GetSelected()
	return {}
end

function SELF:SetSelected(data)
end

function SELF:Update()
	self.Interface:UpdateWindow(self.Id, self)
end

function SELF:Close()
	self.Interface:Close()
end

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	callback(self, interfaceData, ply, buttonId)
end
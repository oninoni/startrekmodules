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
--     LCARS Target Info | Server    --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(targetId, simple, hFlip)
	local success = SELF.Base.OnCreate(self, "Target Information", "TARGET", hFlip)
	if not success then
		return false
	end

	self.Simple = simple
	self.TargetId = targetId

	return true
end

function SELF:GetClientData()
	local clientData = SELF.Base.GetClientData(self)

	clientData.Simple = self.Simple
	clientData.TargetId = self.TargetId

	return clientData
end

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	local shouldUpdate = false

	-- TODO

	return shouldUpdate
end
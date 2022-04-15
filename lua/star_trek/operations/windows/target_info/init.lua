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

function SELF:OnCreate(targetName, hFlip)
	local success = SELF.Base.OnCreate(self, targetName, "TARGET", hFlip)
	if not success then
		return false
	end

	-- TODO

	return true
end

function SELF:GetClientData()
	local clientData = SELF.Base.GetClientData(self)

	-- TODO

	return clientData
end

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	local shouldUpdate = false

	-- TODO

	return shouldUpdate
end
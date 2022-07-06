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
--     LCARS System Map | Server     --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(systemName, hFlip)
	local success = SELF.Base.OnCreate(self, systemName or "Unknown System", "LOCAL", hFlip)
	if not success then
		return false
	end

	-- TODO

	return self
end


function SELF:GetClientData()
	local clientData = SELF.Base.GetClientData(self)

	-- TODO

	return clientData
end

function SELF:GetSelected()
	local data = {}

	-- TODO

	return data
end

function SELF:SetSelected(data)
	-- TODO
end

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	local shouldUpdate = false

	-- TODO

	return shouldUpdate
end
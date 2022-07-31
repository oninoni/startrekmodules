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
--     LCARS Target Info | Server    --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(targetId, simple, selector, hFlip)
	local success = SELF.Base.OnCreate(self, "Target Information", "TARGET", hFlip)
	if not success then
		return false
	end

	self.TargetId = targetId
	self.Simple = simple
	self.Selector = selector

	return true
end

function SELF:GetClientData()
	local clientData = SELF.Base.GetClientData(self)

	clientData.TargetId = self.TargetId
	clientData.Simple = self.Simple
	clientData.Selector = self.Selector

	return clientData
end

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	if not self.Selector then
		return
	end

	local shouldUpdate = false
	if buttonId == 1 or buttonId == 2 then
		shouldUpdate = true
	end

	if isfunction(callback) then
		callback(self, interfaceData, ply, buttonId)
	end

	if shouldUpdate then
		interfaceData.Ent:EmitSound("star_trek.lcars_beep")
	end

	return shouldUpdate
end
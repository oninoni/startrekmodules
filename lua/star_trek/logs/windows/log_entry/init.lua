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
--      LCARS Log Entry | Server     --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(color, hFlip)
	local success = SELF.Base.OnCreate(self, color, "Logs", "LOGS", hFlip, {})
	if not success then
		return false
	end

	return true
end

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	return SELF.Base.OnPress(self, interfaceData, ply, buttonId, callback)
end

function SELF:UpdateContent()
	local sessionData = self.SessionData
	if not sessionData then
		return false, "Invalid Session Data"
	end

	self:ClearLines()

	-- Initial Information
	self:AddLine("Type: " .. (sessionData.Type or "[MISSING]"), Star_Trek.LCARS.ColorRed)
	self:AddLine("Location: " .. (sessionData.SectionName or "[MISSING]"), Star_Trek.LCARS.ColorOrange)
	self:AddLine("Stardate Started: " .. (sessionData.SessionStarted or "[MISSING]"), Star_Trek.LCARS.ColorLightBlue) -- TODO: Stardate
	self:AddLine("Stardate Archived: " .. (sessionData.SessionArchived or "[ACTIVE]"), Star_Trek.LCARS.ColorLightBlue) -- TODO: Stardate

	local currentName = nil
	for _, entry in pairs(sessionData.Entries) do
		local name = entry.Name
		if name ~= currentName then
			self:AddLine("")
			self:AddLine(name .. ":", Star_Trek.LCARS.ColorOrange)

			currentName = name
		end

		self:AddLine(entry.Text, Star_Trek.LCARS.ColorLightBlue)
	end

	return true
end

function SELF:SetSessionData(sessionData)
	self.SessionData = sessionData

	return self:UpdateContent()
end
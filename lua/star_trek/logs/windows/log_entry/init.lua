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
--      LCARS Log Entry | Server     --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(preventAutoLink, color, hFlip)
	local success = SELF.Base.OnCreate(self, color, "Logs", "LOGS", hFlip, {})
	if not success then
		return false
	end

	self.PreventAutoLink = preventAutoLink or false

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
	self:AddLine(sessionData.Type or "[MISSING]", Star_Trek.LCARS.ColorRed, TEXT_ALIGN_CENTER)
	self:AddLine(sessionData.SectionName or "[MISSING]", Star_Trek.LCARS.ColorOrange, TEXT_ALIGN_CENTER)
	self:AddLine("")

	local startTime = "[MISSING]"
	if isnumber(sessionData.SessionStarted) then
		startTime = Star_Trek.Util:GetStardate(sessionData.SessionStarted)
	end
	self:AddLine("Stardate Started: " .. startTime, Star_Trek.LCARS.ColorLightBlue)

	if Star_Trek.Logs.ShowUTCTime then
		self:AddLine("(" .. os.date("!%B %d %Y - %H:%M:%S UTC", sessionData.SessionStarted) .. ")", Star_Trek.LCARS.ColorLightBlue, TEXT_ALIGN_RIGHT)
	end

	local archiveTime = "[ACTIVE]"
	if isnumber(sessionData.SessionArchived) then
		archiveTime = Star_Trek.Util:GetStardate(sessionData.SessionArchived)
	end
	self:AddLine("Stardate Archived: " .. archiveTime, Star_Trek.LCARS.ColorLightBlue)

	if Star_Trek.Logs.ShowUTCTime then
		self:AddLine("(" .. os.date("!%B %d %Y - %H:%M:%S UTC", sessionData.SessionArchived) .. ")", Star_Trek.LCARS.ColorLightBlue, TEXT_ALIGN_RIGHT)
	end

	local currentName = nil
	for _, entry in pairs(sessionData.Entries or {}) do
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
	local oldSessionData = self.SessionData
	if istable(oldSessionData) and istable(oldSessionData.Watchers) and table.HasValue(oldSessionData.Watchers, v) then
		table.RemoveByValue(oldSessionData.Watchers, self)
	end

	self.SessionData = sessionData
	sessionData.Watchers = sessionData.Watchers or {}

	if not table.HasValue(sessionData.Watchers, self) then
		table.insert(sessionData.Watchers, self)
	end

	return self:UpdateContent()
end
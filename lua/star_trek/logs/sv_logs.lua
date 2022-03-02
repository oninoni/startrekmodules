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
--           Logs | Server           --
---------------------------------------

-- Log status Enums.
ST_LOGS_ACTIVE = 1
ST_LOGS_ARCHIVED = 2
ST_LOGS_DELETED = 3

-- Active Sessions
Star_Trek.Logs.Sessions = Star_Trek.Logs.Sessions or {}

-- Registered Types
Star_Trek.Logs.Types = Star_Trek.Logs.Types or {}

function Star_Trek.Logs:RegisterType(type)
	if table.HasValue(self.Types, type) then
		return
	end

	table.insert(self.Types, type)
end

-- Register the default LCARS Types
hook.Add("Star_Trek.ModulesLoaded", "Star_Trek.Logs.LoadTypes", function()
	for interfaceName, interface in pairs(Star_Trek.LCARS.Interfaces) do
		local type = interface.LogType
		if isstring(type) then
			Star_Trek.Logs:RegisterType(type)
		end
	end
end)

-- Starts a session of the given type.
--
-- @param Entity ent
-- @param Player ply
-- @param String type
-- @return Boolean success
-- @return? String error
function Star_Trek.Logs:StartSession(ent, ply, type)
	if not IsValid(ent) then
		return false, "Invalid Entity"
	end

	if self:GetSession(ent) then
		local success, error = self:EndSession(ent, ply)
		if not success then
			return false, error
		end
	end

	if not isstring(type) then
		return false, "Invalid Session Type"
	end

	local sessionData = {
		Type = type,
		Status = ST_LOGS_ACTIVE,
		SessionStarted = os.time(),
		Entries = {},
	}

	-- TODO: Add Start Session Reason (Add last entry with a given string / ply)

	self.Sessions[ent] = sessionData

	local success, error = self:AddEntry(ent, ply, "Session started.")
	if not success then
		return false, error
	end

	return true
end

-- Hook Implementation
hook.Add("Star_Trek.LCARS.OpenInterface", "Star_Trek.Logs.StartSession", function(interfaceData, ply)
	local logType = hook.Run("Star_Trek.Logs.GetSessionName", interfaceData)
	if not logType then
		logType = interfaceData.LogType
	end

	if logType == false then
		return
	end

	local ent = hook.Run("Star_Trek.Logs.GetSessionEntity", interfaceData)
	if not ent then
		ent = interfaceData.Ent
	end

	local success, error = Star_Trek.Logs:StartSession(ent, ply, logType)
	if not success then
		print(error) -- TODO
	end
end)

-- Returns the session data of the given entity.
--
-- @param Entity ent
-- @return? Table sessionData
function Star_Trek.Logs:GetSession(ent)
	local sessionData = self.Sessions[ent]
	if istable(sessionData) then
		return sessionData
	end

	return false
end

-- Adds an entry to the session.
--
-- @param Table sessionData
-- @param Player ply
-- @param String text
-- @return Boolean success
-- @return? String error
function Star_Trek.Logs:AddEntryToSession(sessionData, ply, text)
	local name = "[INTERNAL]"
	if IsValid(ply) and ply:IsPlayer() then
		name = hook.Run("Star_Trek.GetPlayerName", ply) -- TODO: Implement in Gamemode
		if not isstring(name) then
			name = ply:Name()
		end
	end

	if not isstring(text) then
		return false, "Invalid message."
	end

	local entryData = {
		Name = name,
		Text = text,
	}

	table.insert(sessionData.Entries, entryData)

	return true
end

-- Adds an entry to the session of the entity.
--
-- @param Entity ent
-- @param Player ply
-- @param String text
-- @return Boolean success
-- @return? String error
function Star_Trek.Logs:AddEntry(ent, ply, text)
	local sessionData = self:GetSession(ent)
	if not sessionData then
		return false, "Entity does not have an active session"
	end

	local success, error = self:AddEntryToSession(sessionData, ply, text)
	if not success then
		return false, error
	end

	return true
end

-- Ends the session of the given entity.
--
-- @param Entity ent
-- @param Player ply
-- @return Boolean success
-- @return? String error
function Star_Trek.Logs:EndSession(ent)
	local sessionData = self:GetSession(ent)
	if not sessionData then
		return true
	end

	local success, error = self:AddEntry(ent, nil, "Session terminated.")
	if not success then
		return false, error
	end

	local success2, error2 = self:ArchiveSession(sessionData, function(success)
		if not success then
			print("ERROR while storing session.")
			PrintTable(sessionData)
		end
	end)
	if not success2 then
		return false, error2
	end

	self.Sessions[ent] = nil

	return true
end

-- Hook Implementation
hook.Add("Star_Trek.LCARS.PreCloseInterface", "Star_Trek.Logs.EndSession", function(interfaceData)
	local ent = hook.Run("Star_Trek.Logs.GetSessionEntity", interfaceData)
	if not ent then
		ent = interfaceData.Ent
	end

	local success, error = Star_Trek.Logs:EndSession(ent)
	if not success then
		print(error) -- TODO
	end
end)
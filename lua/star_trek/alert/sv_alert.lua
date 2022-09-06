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
--           Alert | Server          --
---------------------------------------

-- Enable the given alert.
--
-- @param String alert
-- @return Boolean success
-- @return? String error
util.AddNetworkString("Star_Trek.Alert.Enable")
function Star_Trek.Alert:Enable(type)
	local alertType = self.AlertTypes[type]
	if not istable(alertType) then
		return false, "Invalid alert!"
	end

	if isstring(self.ActiveAlert) and self.ActiveAlert == type then
		return false, "Alert mode already active."
	end

	if self.ActiveAlertSound then
		self.ActiveAlertSound:Stop()
	end

	if isstring(alertType.Sound) then
		filter = RecipientFilter()
		filter:AddAllPlayers()

		self.ActiveAlertSound = CreateSound(game.GetWorld(), alertType.Sound, filter)
		if self.ActiveAlertSound then
			self.ActiveAlertSound:SetSoundLevel(0)
			self.ActiveAlertSound:Play()
		end
	end

	local bridgeLights = ents.FindByName(Star_Trek.Alert.BridgeDimName)
	for _, ent in pairs(bridgeLights) do
		if alertType.BridgeDim then
			ent:Fire("turnOff")
		else
			ent:Fire("turnOn")
		end
	end

	net.Start("Star_Trek.Alert.Enable")
		net.WriteString(type)
	net.Broadcast()

	self.ActiveAlert = type

	return true
end

-- Sync Alert on Join.
hook.Add("PlayerInitialSpawn", "Star_Trek.Alert.Sync", function()
	if isstring(Star_Trek.Alert.ActiveAlert) then
		net.Start("Star_Trek.Alert.Enable")
			net.WriteString(Star_Trek.Alert.ActiveAlert)
		net.Broadcast()
	end
end)

-- Disable the current alert.
--
-- @return Boolean success
-- @return? String error
util.AddNetworkString("Star_Trek.Alert.Disable")
function Star_Trek.Alert:Disable()
	if not self.ActiveAlert then
		return false, "Alert already inactive."
	end

	if self.ActiveAlertSound then
		self.ActiveAlertSound:Stop()
	end

	local bridgeLights = ents.FindByName(Star_Trek.Alert.BridgeDimName)
	for _, ent in pairs(bridgeLights) do
		ent:Fire("turnOn")
	end

	net.Start("Star_Trek.Alert.Disable")
	net.Broadcast()

	self.ActiveAlert = nil

	return true
end

hook.Add("PostCleanupMap", "Star_Trek.Alert.Cleanup", function()
	Star_Trek.Alert:Disable()
end)

hook.Add("Star_Trek.ModulesLoaded", "Star_Trek.Alert.LoadLogType", function()
	if istable(Star_Trek.Logs) then
		Star_Trek.Logs:RegisterType("Alert Master Control")
	end
end)

hook.Add("Star_Trek.Logs.GetSessionName", "Star_Trek.Alert.GetSessionName", function(interfaceData)
	local ent = interfaceData.Ent
	if ent:GetName() == "bridgeBut1" then
		return "Alert Master Control"
	end
end)

hook.Add("Star_Trek.LCARS.BasicPressed", "Star_Trek.Alert.BasicPressed", function(ply, interfaceData, buttonId, buttonData)
	local ent = interfaceData.Ent
	if ent:GetName() == "bridgeBut1" and istable(Star_Trek.Logs) then
		if buttonId == 1 then
			Star_Trek.Logs:AddEntry(ent, ply, "Yellow Alert!")
		elseif buttonId == 2 then
			Star_Trek.Logs:AddEntry(ent, ply, "Red Alert!")
		elseif buttonId == 3 then
			Star_Trek.Logs:AddEntry(ent, ply, "Alert Disabled!")
		end
	end
end)
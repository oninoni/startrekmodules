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
--         Warp Core | Client        --
---------------------------------------

util.AddNetworkString("Star_Trek.WarpCore.SetSpeed")
function Star_Trek.WarpCore:SetWarpCoreVars(speed, brightness, flashSpeed, flashMin, flashMax)
	self.WarpCoreSpeed = speed or 0.05
	self.WarpCoreBrightness = brightness or 0.7
	self.WarpCoreFlashSpeed = flashSpeed or 4
	self.WarpCoreFlashMin = flashMin or 0.8
	self.WarpCoreFlashMax = flashMax or 1.2

	net.Start("Star_Trek.WarpCore.SetSpeed")
		net.WriteFloat(self.WarpCoreSpeed)
		net.WriteFloat(self.WarpCoreBrightness)
		net.WriteFloat(self.WarpCoreFlashSpeed)
		net.WriteFloat(self.WarpCoreFlashMin)
		net.WriteFloat(self.WarpCoreFlashMax)
	net.Broadcast()
end

function Star_Trek.WarpCore:SetWarp(value)
	if value == 0 then
		self:SetWarpCoreVars()
	elseif value == 1 then
		self:SetWarpCoreVars(0.5, 1.5, 2)
	elseif value == -1 then
		self:SetWarpCoreVars(0.01, 0.3)
	end
end

-- Alias for Map.
function Star_Trek.Util:SetWarp(value)
	Star_Trek.WarpCore:SetWarp(value)
end

hook.Add("PlayerInitialSpawn", "Star_Trek.WarpCore.Sync", function(ply)
	local speed = Star_Trek.WarpCore.WarpCoreSpeed
	local brightness = Star_Trek.WarpCore.WarpCoreBrightness
	local flashSpeed = Star_Trek.WarpCore.WarpCoreFlashSpeed
	local flashMin = Star_Trek.WarpCore.WarpCoreFlashMin
	local flashMax = Star_Trek.WarpCore.WarpCoreFlashMax

	if isnumber(speed) then
		net.Start("Star_Trek.WarpCore.SetSpeed")
			net.WriteFloat(speed or 0.05)
			net.WriteFloat(brightness or 0.7)
			net.WriteFloat(flashSpeed or 4)
			net.WriteFloat(flashMin or 0.8)
			net.WriteFloat(flashMax or 1.2)
		net.Send(ply)
	end
end)

hook.Add("Star_Trek.ModulesLoaded", "Star_Trek.WarpCore.LoadLogType", function()
	if istable(Star_Trek.Logs) then
		Star_Trek.Logs:RegisterType("Warp Core Control")
	end
end)

hook.Add("Star_Trek.Logs.GetSessionName", "Star_Trek.WarpCore.GetSessionName", function(interfaceData)
	local ent = interfaceData.Ent
	if ent:GetName() == "coreBut1" then
		return "Warp Core Control"
	end
end)

hook.Add("Star_Trek.LCARS.BasicPressed", "Star_Trek.WarpCore.BasicPressed", function(ply, interfaceData, buttonId)
	local ent = interfaceData.Ent
	if ent:GetName() == "coreBut1" and istable(Star_Trek.Logs) then
		if buttonId == 1 then
			Star_Trek.Logs:AddEntry(ent, ply, "Force Field enabled!")
		elseif buttonId == 2 then
			Star_Trek.Logs:AddEntry(ent, ply, "Force Field disabled!")

			Star_Trek.LCARS:CloseInterface(Star_Trek.WarpCore.Button, callback)
		elseif buttonId == 3 then
			Star_Trek.Logs:AddEntry(ent, ply, "Starting Warp Core Ejection...")

			Star_Trek.LCARS:OpenInterface(ply, Star_Trek.WarpCore.Button, "warp_core_eject")

			return true
		end
	end
end)

function Star_Trek.WarpCore:IsValidCode(code)
	if table.HasValue(Star_Trek.WarpCore.ValidCodes, code) then
		return true
	end

	return false
end
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
--       Utilities | Warp Core       --
---------------------------------------

util.AddNetworkString("Star_Trek.Util.SetWarpCore")
function Star_Trek.Util:SetWarpCoreVars(speed, brightness, flashSpeed, flashMin, flashMax)
	self.WarpCoreSpeed = speed or 0.05
	self.WarpCoreBrightness = brightness or 0.7
	self.WarpCoreFlashSpeed = flashSpeed or 4
	self.WarpCoreFlashMin = flashMin or 0.8
	self.WarpCoreFlashMax = flashMax or 1.2

	net.Start("Star_Trek.Util.SetWarpCore")
		net.WriteFloat(self.WarpCoreSpeed)
		net.WriteFloat(self.WarpCoreBrightness)
		net.WriteFloat(self.WarpCoreFlashSpeed)
		net.WriteFloat(self.WarpCoreFlashMin)
		net.WriteFloat(self.WarpCoreFlashMax)
	net.Broadcast()
end

function Star_Trek.Util:SetWarp(value)
	if value == 0 then
		self:SetWarpCoreVars()
	elseif value == 1 then
		self:SetWarpCoreVars(0.5, 1.5, 2)
	elseif value == -1 then
		self:SetWarpCoreVars(0.01, 0.3)
	end
end

hook.Add("PlayerInitialSpawn", "WarpCoreSync", function(ply)
	local speed = Star_Trek.Util.WarpCoreSpeed
	local brightness = Star_Trek.Util.WarpCoreBrightness
	local flashSpeed = Star_Trek.Util.WarpCoreFlashSpeed
	local flashMin = Star_Trek.Util.WarpCoreFlashMin
	local flashMax = Star_Trek.Util.WarpCoreFlashMax

	if isnumber(speed) then
		net.Start("Star_Trek.Util.SetWarpCore")
			net.WriteFloat(speed or 0.05)
			net.WriteFloat(brightness or 0.7)
			net.WriteFloat(flashSpeed or 4)
			net.WriteFloat(flashMin or 0.8)
			net.WriteFloat(flashMax or 1.2)
		net.Send(ply)
	end
end)

hook.Add("Star_Trek.ModulesLoaded", "Star_Trek.Warp.LoadLogType", function()
	Star_Trek.Logs:RegisterType("Warp Core Control")
end)

hook.Add("Star_Trek.Logs.GetSessionName", "Star_Trek.Warp.GetSessionName", function(interfaceData)
	local ent = interfaceData.Ent
	if ent:GetName() == "coreBut1" then
		return "Warp Core Control"
	end
end)

hook.Add("Star_Trek.LCARS.BasicPressed", "Star_Trek.Warp.BasicPressed", function(ply, interfaceData, buttonId)
	local ent = interfaceData.Ent
	if ent:GetName() == "coreBut1" then
		if buttonId == 1 then
			Star_Trek.Logs:AddEntry(ent, ply, "Force Field enabled!")
		elseif buttonId == 2 then
			Star_Trek.Logs:AddEntry(ent, ply, "Force Field disabled!")
		elseif buttonId == 3 then
			Star_Trek.Logs:AddEntry(ent, ply, "Warp Core ejected!")
		end
	end
end)
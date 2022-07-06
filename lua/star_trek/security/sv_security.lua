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
--         Security | Server         --
---------------------------------------

local subConsoles = {
	"sickbayButton",
	"transporterBut1",
	"securityButton",
	"brigButton1",
	"brigButton2",
	"brigButton3",
	"brigButton4",
}

hook.Add("Star_Trek.ModulesLoaded", "Star_Trek.Security.LoadLogType", function()
	if istable(Star_Trek.Logs) then
		Star_Trek.Logs:RegisterType("Security Sub-Console")
	end
end)

hook.Add("Star_Trek.Logs.GetSessionName", "Star_Trek.Security.GetSessionName", function(interfaceData)
	local ent = interfaceData.Ent
	if table.HasValue(subConsoles, ent:GetName()) then
		return "Security Sub-Console"
	end
end)

hook.Add("Star_Trek.LCARS.BasicPressed", "Star_Trek.Security.BasicPressed", function(ply, interfaceData, buttonId)
	local ent = interfaceData.Ent
	if table.HasValue(subConsoles, ent:GetName()) and istable(Star_Trek.Logs) then
		if ent:GetName() == "securityButton" then
			if buttonId == 1 then
				Star_Trek.Logs:AddEntry(ent, ply, "Door Locked!")
			elseif buttonId == 2 then
				Star_Trek.Logs:AddEntry(ent, ply, "Door Unlocked!")
			elseif buttonId == 3 then
				Star_Trek.Logs:AddEntry(ent, ply, "Force Field Enabled!")
			elseif buttonId == 4 then
				Star_Trek.Logs:AddEntry(ent, ply, "Force Field Disabled!")
			end
		else
			if buttonId == 1 then
				Star_Trek.Logs:AddEntry(ent, ply, "Force Field Enabled!")
			elseif buttonId == 2 then
				Star_Trek.Logs:AddEntry(ent, ply, "Force Field Disabled!")
			end
		end
	end
end)
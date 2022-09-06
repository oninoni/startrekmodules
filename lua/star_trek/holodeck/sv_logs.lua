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
--       Holodeck Logs | Server      --
---------------------------------------

hook.Add("Star_Trek.ModulesLoaded", "Star_Trek.Holodeck.LoadLogType", function()
	if istable(Star_Trek.Logs) then
		Star_Trek.Logs:RegisterType("Holodeck")
	end
end)

hook.Add("Star_Trek.Logs.GetSessionName", "Star_Trek.Holodeck.GetSessionName", function(interfaceData)
	local ent = interfaceData.Ent

	local name = ent:GetName()
	if string.StartWith(name, "holoDeckButton") or string.StartWith(name, "holoProgrammButton") then
		return false
	end
end)

hook.Add("Star_Trek.LCARS.BasicPressed", "Star_Trek.Holodeck.BasicPressed", function(ply, interfaceData, buttonId, buttonData)
	local ent = interfaceData.Ent
	if istable(Star_Trek.Logs) then

		local name = ent:GetName()
		if string.StartWith(name, "holoDeckButton") then
			Star_Trek.Logs:StartSession(ent, ply, "Holodeck")
			Star_Trek.Logs:AddEntry(ent, ply, "Loading: " .. buttonData.Name)
		end
	end
end)
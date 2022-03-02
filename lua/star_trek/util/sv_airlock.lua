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
--        Utilities | Airlock        --
---------------------------------------

hook.Add("Star_Trek.ModulesLoaded", "Star_Trek.Airlock.LoadLogType", function()
	if istable(Star_Trek.Logs) then
		Star_Trek.Logs:RegisterType("Airlock Control")
	end
end)

hook.Add("Star_Trek.Logs.GetSessionName", "Star_Trek.Airlock.GetSessionName", function(interfaceData)
	local ent = interfaceData.Ent
	if ent:GetName() == "airlockButInner" or ent:GetName() == "airlockButOuther" then
		return "Airlock Control"
	end
end)

hook.Add("Star_Trek.LCARS.BasicPressed", "Star_Trek.Airlock.BasicPressed", function(ply, interfaceData, buttonId)
	local ent = interfaceData.Ent
	if istable(Star_Trek.Logs) then
		if ent:GetName() == "airlockButInner" then
			if buttonId == 1 then
				local buttonData = interfaceData.Windows[1].Buttons[buttonId]
				if buttonData.Name == "Unlock inner Door" then
					Star_Trek.Logs:AddEntry(ent, ply, "Inner Door unlocked!")
				elseif buttonData.Name == "Lock inner Door" then
					Star_Trek.Logs:AddEntry(ent, ply, "Inner Door locked!")
				end
			elseif buttonId == 2 then
				local buttonData = interfaceData.Windows[1].Buttons[buttonId]
				if buttonData.Name == "Open outher Door" then
					Star_Trek.Logs:AddEntry(ent, ply, "Outer Door opened!")
					local pressureButtonData = interfaceData.Windows[1].Buttons[3]
					if pressureButtonData.Disabled then
						Star_Trek.Logs:AddEntry(ent, ply, "Warning! Pressure Lost!")
					end
				elseif buttonData.Name == "Lock outher Door" then
					Star_Trek.Logs:AddEntry(ent, ply, "Inner Door locked!")
				end
			elseif buttonId == 3 then
				Star_Trek.Logs:AddEntry(ent, ply, "Force Field pressurized!")
			elseif buttonId == 4 then
				Star_Trek.Logs:AddEntry(ent, ply, "Force Field depressurized!")
			elseif buttonId == 5 then
				Star_Trek.Logs:AddEntry(ent, ply, "Outer Console locked!")
			elseif buttonId == 6 then
				Star_Trek.Logs:AddEntry(ent, ply, "Outer Console unlocked!")
			end
		elseif ent:GetName() == "airlockButOuther" then
			if buttonId == 1 then
				local buttonData = interfaceData.Windows[1].Buttons[buttonId]
				if buttonData.Name == "Unlock inner Door" then
					Star_Trek.Logs:AddEntry(ent, ply, "Inner Door unlocked!")
				elseif buttonData.Name == "Lock inner Door" then
					Star_Trek.Logs:AddEntry(ent, ply, "Inner Door locked!")
				end
			elseif buttonId == 2 then
				local buttonData = interfaceData.Windows[1].Buttons[buttonId]
				if buttonData.Name == "Unlock outher Door" then
					Star_Trek.Logs:AddEntry(ent, ply, "Outer Door unlocked!")
				elseif buttonData.Name == "Lock outher Door" then
					Star_Trek.Logs:AddEntry(ent, ply, "Inner Door locked!")
				end
			elseif buttonId == 3 then
				Star_Trek.Logs:AddEntry(ent, ply, "Force Field pressurized!")
			elseif buttonId == 4 then
				Star_Trek.Logs:AddEntry(ent, ply, "Force Field depressurized!")
			end
		end
	end
end)
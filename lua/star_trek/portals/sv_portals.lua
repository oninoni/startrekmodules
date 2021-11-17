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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--          Portals | Server         --
---------------------------------------

-- Add all portal visleafs to server's potentially visible set
hook.Add("SetupPlayerVisibility", "WorldWindows_AddPVS", function(ply, ent)
	for _, portal in ipairs(ents.FindByClass("linked_portal_window")) do
		local exit = portal:GetExit()
		if IsValid(exit) then
			AddOriginToPVS(exit:GetPos())
		end
	end
end)

local viewScreen = ents.FindByName("viewScreen")[1]
local target = viewScreen:GetExit()

timer.Create("Test", 0, 0, function()
	print("---")

	local pos = target:GetPos() + Vector(0, 0, 0)
	target:SetPos(Vector(0, 0, 0))
	print(pos)

	local ang = target:GetAngles() + Angle(0, 0, 0)
	target:SetAngles(ang)
	print(ang)
end)
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
--    Copyright © 2020 Jan Ziegler   --
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
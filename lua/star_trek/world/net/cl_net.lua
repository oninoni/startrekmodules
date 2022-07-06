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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--       World Network | Client      --
---------------------------------------

net.Receive("Star_Trek.World.Load", function()
	local id = net.ReadInt(32)
	local class = net.ReadString()

	local success, error = Star_Trek.World:LoadEntity(id, class)
	if not success then
		print(error)
	end
end)

net.Receive("Star_Trek.World.UnLoad", function()
	local id = net.ReadInt(32)

	Star_Trek.World:UnLoadEntity(id)
end)

net.Receive("Star_Trek.World.Update", function()
	local id = net.ReadInt(32)

	local ent = Star_Trek.World.Entities[id]
	if ent then
		ent:ReadData()
		ent:ReadDynData()
	end
end)

net.Receive("Star_Trek.World.Sync", function()
	local id = net.ReadInt(32)

	local ent = Star_Trek.World.Entities[id]
	if ent then
		ent:ReadDynData()
	end
end)
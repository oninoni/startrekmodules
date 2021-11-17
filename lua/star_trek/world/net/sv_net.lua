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
--       World Network | Server      --
---------------------------------------

util.AddNetworkString("Star_Trek.World.Load")
util.AddNetworkString("Star_Trek.World.UnLoad")
util.AddNetworkString("Star_Trek.World.Sync")

-- Network a newly loaded world entity to the clients.
function Star_Trek.World:NetworkLoad(id, ent)
	net.Start("Star_Trek.World.Load")
		net.WriteInt(id, 32)
		net.WriteString(ent.Class)
		ent:WriteData()
	net.Broadcast()

	return true
end

-- Network all loaded world entities to a client.
function Star_Trek.World:NetworkLoaded(ply)
	for id, ent in pairs(self.Entities) do -- TODO: Optimise with comression and combined messages
		net.Start("Star_Trek.World.Load")
			net.WriteInt(id, 32)
			net.WriteString(ent.Class)
			ent:WriteData()
		net.Broadcast()
	end

	return true
end

-- Network the unloading of a world entity to all clients.
function Star_Trek.World:NetworkUnLoad(id)
	net.Start("Star_Trek.World.UnLoad")
		net.WriteInt(id, 32)
	net.Broadcast()
	
	return true
end

-- Synchronize the dynamic data of all loaded world entities to all players.
function Star_Trek.World:NetworkSync()
	for id, ent in pairs(self.Entities) do -- TODO: Optimise with comression and combined messages
		-- TODO: Don't Sync non-Dynamic Entities
		net.Start("Star_Trek.World.Sync")
			net.WriteInt(id, 32)
			ent:WriteDynData()
		net.Broadcast()
	end
	
	return true
end
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
--       World Network | Server      --
---------------------------------------

util.AddNetworkString("Star_Trek.World.Load")
util.AddNetworkString("Star_Trek.World.UnLoad")
util.AddNetworkString("Star_Trek.World.Update")
util.AddNetworkString("Star_Trek.World.Sync")

-- Network a newly loaded world entity to the clients.
function Star_Trek.World:NetworkLoad(ent)
	net.Start("Star_Trek.World.Load")
		net.WriteInt(ent.Id, 32)
		net.WriteString(ent.Class)
		ent:WriteData()
		ent:WriteDynData()
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
			ent:WriteDynData()
		net.Send(ply)
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

-- Update all data of the given entity.
function Star_Trek.World:NetworkUpdate(ent)
	net.Start("Star_Trek.World.Update")
		net.WriteInt(ent.Id, 32)
		ent:WriteData()
		ent:WriteDynData()
	net.Broadcast()
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
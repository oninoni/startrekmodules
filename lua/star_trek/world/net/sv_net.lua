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
function Star_Trek.World:NetworkLoad(id, ent)
	local data = ent:GetData()
	if not istable(data) then
		return false, "Invalid Data"
	end

	data.Class = ent.Class

	net.Start("Star_Trek.World.Load")
		net.WriteInt(id, 32)
		net.WriteTable(data) -- TODO: Optimise
	net.Broadcast()

	return true
end

util.AddNetworkString("Star_Trek.World.LoadAll")
function Star_Trek.World:NetworkLoaded(ply)
	local allData = {}

	for id, ent in pairs(self.Entities) do
		local data = ent:GetData()
		if not istable(data) then
			return false, "Invalid Data on " .. id
		end

		data.Class = ent.Class

		allData[id] = data
	end

	net.Start("Star_Trek.World.LoadAll")
		net.WriteTable(allData) -- TODO: Optimise
	net.Broadcast()

	return true
end

util.AddNetworkString("Star_Trek.World.UnLoad")
function Star_Trek.World:NetworkUnLoad(id)
	net.Start("Star_Trek.World.UnLoad")
		net.WriteInt(id, 32)
	net.Broadcast()

	return true
end

util.AddNetworkString("Star_Trek.World.Sync")
function Star_Trek.World:NetworkSync()
	local data = {}

	for id, ent in pairs(self.Entities) do
		data[id] = ent:GetDynData()
	end

	net.Start("Star_Trek.World.Sync")
		net.WriteTable(data) -- TODO: Optimise
	net.Broadcast()
end

-- TODO: Test between spacing out Sync to multiple users and space our Objects vs the "All at once" implementation above.
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
--       World Network | Client      --
---------------------------------------

local function fixBigVectors(data)
	for k, v in pairs(data) do
		print(k, v)
		if istable(v) then
			PrintTable(v)
		end
	end
end

net.Receive("Star_Trek.World.Load", function()
	local id = net.ReadInt(32)
	local data = net.ReadTable()

	fixBigVectors(data)

	local success, error = Star_Trek.World:LoadEntity(id, data.Class, data)
	if not success then
		print(error)
	end
end)

net.Receive("Star_Trek.World.LoadAll", function()
	local allData = net.ReadTable()

	for id, data in pairs(allData) do
		fixBigVectors(data)

		local success, error = Star_Trek.World:LoadEntity(id, data.Class, data)
		if not success then
			print(error)
		end
	end
end)

net.Receive("Star_Trek.World.UnLoad", function()
	local id = net.ReadInt(32)

	Star_Trek.World:UnLoadEntity(id)
end)

-- TODO: Maybe more custom to be more efficient?
net.Receive("Star_Trek.World.Sync", function()
	--local data = net.ReadTable()
	local n = net.ReadInt(32)
	local dataString = net.ReadData(n)

	local data = util.JSONToTable(util.Decompress(dataString))

	for id, dynData in pairs(data) do
		fixBigVectors(dynData)

		local ent = Star_Trek.World.Entities[id]

		--print(dynData.Pos)

		ent:SetDynData(dynData)
	end
end)
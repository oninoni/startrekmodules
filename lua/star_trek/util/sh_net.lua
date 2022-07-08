
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
--   Utilities Networking | Shared   --
---------------------------------------

function Star_Trek.Util:ReadNetTable()
	local size = net.ReadUInt(32)
	local compressedData = net.ReadData(size)

	return util.JSONToTable(util.Decompress(compressedData))
end

function Star_Trek.Util:WriteNetTable(data)
	local compressedData = util.Compress(util.TableToJSON(data))

	local size = #compressedData

	net.WriteUInt(size, 32)
	net.WriteData(compressedData, size)
end
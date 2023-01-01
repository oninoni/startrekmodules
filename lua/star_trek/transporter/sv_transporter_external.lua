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
--   Transporter External | Server   --
---------------------------------------

Star_Trek.Transporter.Externals = Star_Trek.Transporter.Externals or {}
Star_Trek.Transporter.Jammers = Star_Trek.Transporter.Jammers or {} 

-- Request all External Makers available to the interface.
--
-- @param Table interface
-- @param? Bool skipNetworked
-- @return Table externalMarkers
function Star_Trek.Transporter:GetExternalMarkers(interface, skipNetworked)
	local externalMarkers = {}

	-- Tool Placed Externals
	for id, externalData in pairs(self.Externals) do
		local name = "Transporter Location " .. id
		if isstring(externalData.Name) and externalData.Name ~= "" then
			name = externalData.Name
		end

		externalMarkers[id] = {
			Name = name,
			Pos = externalData.Pos
		}
	end

	hook.Run("Star_Trek.Transporter.AddExternalMarkers", interface, externalMarkers, skipNetworked)

	return externalMarkers
end

-- Request all Transporter Rooms available to the interface.
--
-- @param Table interface
-- @param? Bool skipNetworked
-- @return Table externalMarkers
function Star_Trek.Transporter:GetTransporterRooms(interface, skipNetworked)
	interface = interface or {}

	local pads = {}

	-- Map Entities.
	for _, pad in pairs(ents.GetAll()) do
		local name = pad:GetName()
		if isstring(name) and string.StartWith(name, "TRPad") then
			if istable(interface.PadEntities) and table.HasValue(interface.PadEntities or {}, pad) then continue end

			local idString = string.sub(name, 6)
			local split = string.Split(idString, "_")
			local roomId = tonumber(split[2])

			local roomName = "Transporter Room " .. roomId

			local roomData = pads[roomId] or {
				Name = roomName,
				Pads = {}
			}

			table.insert(roomData.Pads, pad)

			pads[roomId] = roomData
		end
	end

	hook.Run("Star_Trek.Transporter.AddRooms", interface, pads, skipNetworked)

	return pads
end

concommand.Add("test", function()

	print("Jammers: ")
	for _, jam in pairs(Star_Trek.Transporter.Jammers) do
		for key, val in pairs(jam) do
			print(key, val)
		end
	end

end)
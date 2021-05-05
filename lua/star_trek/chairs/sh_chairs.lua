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
--         Chairs | Vehicles         --
---------------------------------------

-- Creates the entities from the model to allow placing the chairs as vehicles.
for model, name in pairs(Star_Trek.Chairs.ModelNames) do
	local split = string.Split(model, "/")
	split = string.Split(split[#split], ".")
	local entityName = split[1]

	local vehicleTable = {
		Name = name,
		Model = model,
		Class = "prop_vehicle_prisoner_pod",
		Category = "Star Trek Chairs",
		Author = "Oninoni",
		KeyValues = {
			vehiclescript = "scripts/vehicles/prisoner_pod.txt",
		},
	}

	list.Set("Vehicles", entityName, vehicleTable)
end
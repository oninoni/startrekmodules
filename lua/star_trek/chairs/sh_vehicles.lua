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

local function createVehicles()
    for name, model in pairs(Star_Trek.Chairs.Models) do
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
end

createVehicles()
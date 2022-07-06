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
--           World | Server          --
---------------------------------------

local function addTestingShip(id, pos, model)
	local success, worldEnt = Star_Trek.World:LoadEntity(id, "ship",
		WorldVector(0, 0, 0, pos.x, pos.y, pos.z),
		Angle(),
		model or "models/hunter/blocks/cube1x1x1.mdl",
		Star_Trek.World.Skybox_Scale
	)

	if not success then
		return false, worldEnt
	end

	return worldEnt
end

local function addPlanet(id, pos, model, radius, spin)
	local success, worldEnt = Star_Trek.World:LoadEntity(id, "planet",
		WorldVector(0, 0, 0, pos.x, pos.y, pos.z), Angle(), model, radius, spin
	)

	if not success then
		return false, worldEnt
	end

	return worldEnt
end

local ship
timer.Simple(0, function()
	ship = addTestingShip(1, Vector())

	local earthRadius = 6371000
	local earthDistance = earthRadius + 42164000
	local earthPos = Vector(Star_Trek.World:MeterToSkybox(earthDistance), 0, 0)
	local earth = addPlanet(2, earthPos, "models/planets/earth.mdl", Star_Trek.World:MeterToSkybox(earthRadius), 1)

	local moonRadius = 1737400
	local moonDistance = 356500000
	local moonPos = earthPos + Vector(-Star_Trek.World:MeterToSkybox(moonDistance), 0, 0)
	local moon = addPlanet(3, moonPos, "models/planets/luna_big.mdl", Star_Trek.World:MeterToSkybox(moonRadius))

	local sunRadius = 696340000
	local sunDistance = 150000000000
	local sunPos = earthPos + Vector(-Star_Trek.World:MeterToSkybox(sunDistance), 0, 0)
	local sun = addPlanet(4, sunPos, "models/planets/sun.mdl", Star_Trek.World:MeterToSkybox(sunRadius))
end)

hook.Add("Star_Trek.LCARS.BasicPressed", "WarpDrive.Weeee", function(ply, interfaceData, buttonId)
	local ent = interfaceData.Ent
	local name = ent:GetName()

	if name == "connBut4" then
		if buttonId == 1 then
			timer.Simple(5, function()
				local c = Star_Trek.World:WarpToC(9)
				ship:SetVelocity(Vector(-Star_Trek.World:KilometerToSkybox(300000 * c), 0, 0))
			end)
		else
			timer.Simple(2, function()
				ship:SetVelocity(Vector(0, 0, 0))
			end)
		end
	end
end)

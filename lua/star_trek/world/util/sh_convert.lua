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
--       Size Convert | Shared       --
---------------------------------------

local UNIT_PER_FOOT  = 16
local FOOT_PER_METER = 3.28084
local UNIT_PER_METER = UNIT_PER_FOOT * FOOT_PER_METER

local SKYBOX_SCALE = 1 / Star_Trek.World.Skybox_Scale

function Star_Trek.World:GetModelDiameter(model)
	local ent = ents.Create("prop_physics")
	ent:SetModel(model)
	ent:Spawn()

	local min, max = ent:GetModelBounds()
	SafeRemoveEntity(ent)

	local scale = max - min
	return math.max(
		math.abs(scale.x),
		math.abs(scale.y),
		math.abs(scale.z)
	)
end

-- Return the units representing the meters given.
-- 
-- @param Number m
-- @return Number u
function Star_Trek.World:MeterToUnits(m)
	return m * UNIT_PER_METER
end

-- Return the units representing the meters given.
-- 
-- @param Number u
-- @return Number m
function Star_Trek.World:UnitsToMeter(u)
	return u / UNIT_PER_METER
end

----------------
--   Skybox   --
----------------

-- Return the units in the skybox representing the meters given.
-- 
-- @param Number m
-- @return Number sU
function Star_Trek.World:MeterToSkybox(m)
	return self:MeterToUnits(m) / SKYBOX_SCALE
end

-- Return the units in the skybox representing the kilometers given.
-- 
-- @param Number m
-- @return Number sU
function Star_Trek.World:KilometerToSkybox(km)
	return self:MeterToSkybox(km * 1000)
end

----------------
-- Warp Scale --
----------------

-- Return the multiples of c for a given warp factor.
-- 
-- @param Number warpFactor
-- @return Number c
function Star_Trek.World:WarpToC(warpFactor)
	if warpFactor <= 9 then
		return math.pow(warpFactor, 10 / 3)
	else
		return 0 -- TODO
	end
end
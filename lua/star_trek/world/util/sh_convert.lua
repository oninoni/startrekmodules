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
--       Size Convert | Shared       --
---------------------------------------

local UNIT_PER_FOOT  = 16
local FOOT_PER_METER = 3.28084
local UNIT_PER_METER = UNIT_PER_FOOT * FOOT_PER_METER

local SKYBOX_SCALE = 1024

function Star_Trek.World:MeterToUnits(m)
	return m * UNIT_PER_METER
end

function Star_Trek.World:SkyboxMeter(m)
	return self:MeterToUnits(m) / SKYBOX_SCALE
end

function Star_Trek.World:SkyboxKilometer(km)
	return self:SkyboxMeter(km / 1000)
end
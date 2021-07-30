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
--       World Vector | Shared       --
---------------------------------------

Star_Trek.World.Vector = {}

local BIG_SCALE = (1024 * 1024 * 1024 * 8)
-- 8.589.934.592 Skybox Units
-- 167.576.548.336 Meter
-- Ist ~ 1 AU

-- 149.597.870.700 Meter
-- 7.852.392.233.043 Units
-- 7.668.351.790 Skybox Units
-- ist wirklich ne AU
BIG_SCALE = 7668351790

-- Add the given Vector or World Vector to the World Vector
--
-- @param WorldVector a
-- @param WorldVector/Vector b
-- @return WorldVector result
local function __add(a, b)
	if isvector(b) then
		return WorldVector(a[1], a[2] + b)
	end

	return WorldVector(a[1] + b[1], a[2] + b[2])
end

-- Substract the given Vector or World Vector from the World Vector
--
-- @param WorldVector a
-- @param WorldVector/Vector b
-- @return WorldVector result
local function __sub(a, b)
	if isvector(b) then
		return WorldVector(a[1], a[2] - b)
	end

	return WorldVector(a[1] - b[1], a[2] - b[2])
end

-- Mutliplies a given vector with a scalar.
--
-- @param WorldVector a
-- @param Number b
-- @return WorldVector result
local function __mul(a, b)
	return WorldVector(a[1] * b, a[2] * b)
end

-- Divides a given vector by a scalar.
--
-- @param WorldVector a
-- @param Number b
-- @return WorldVector result
local function __div(a, b)
	return WorldVector(a[1] / b, a[2] / b)
end

-- Compares two vectors with each other for being the same.
--
-- @param WorldVector a
-- @param WorldVector b
-- @return Boolean equal
local function  __eq(a, b)
	return (a[1] == b[1]) and (a[2] == b[2])
end

-- Converts the vector into a string, to be printed.
--
-- @param WorldVector a
-- @return Strint string
local function __tostring(a)
	return tostring(a[1]) .. " | " .. tostring(a[2])
end

-- Define the Meta Table here. Optimisation!
local metaTable = {
	__index = Star_Trek.World.Vector,
	__add = __add, -- +
	__sub = __sub, -- -
	__mul = __mul, -- *
	__div = __div, -- /
	__eq  =  __eq, -- ==
	__tostring = __tostring,
}

-- Initialize a Vector.
--
-- @param Vector big
-- @param Vector small
-- @return WorldVector vector
function WorldVector(big, small)
	local worldVector = {Big = big or Vector(), Small = small or Vector()}
	setmetatable(worldVector, metaTable)

	worldVector:FixValue()

	return worldVector
end

-- Reduces the Value to its minimum "Small" Vector Size.
-- Should be called after any operation.
function Star_Trek.World.Vector:FixValue()
	local s = self[2]

	self[2] = Vector(
		s[1] % BIG_SCALE,
		s[2] % BIG_SCALE,
		s[3] % BIG_SCALE
	)

	local temp = (s - self[2]) / 8
	self[1] = Vector(
		self[1][1] + math.floor(temp.x),
		self[1][2] + math.floor(temp.y),
		self[1][3] + math.floor(temp.z)
	)
end

function Star_Trek.World.Vector:ToVector()
	return self[1] * BIG_SCALE + self[2]
end

function Star_Trek.World.Vector:LengthSqr()
	local temp = self[1] * BIG_SCALE + self[2]
	return temp:LengthSqr()
end

function Star_Trek.World.Vector:Length()
	local temp = self[1] * BIG_SCALE + self[2]
	return temp:Length()
end

function WorldToLocalBig(pos, ang, newSystemOrigin, newSystemAngles)
	local offsetPos = pos - newSystemOrigin

	return WorldToLocal(offsetPos:ToVector(), ang, Vector(), newSystemAngles)
end

function net.ReadWorldVector()
	local big   = net.ReadVector()
	local small = net.ReadVector()

	return WorldVector(big, small)
end

function net.WriteWorldVector(vec)
	net.WriteVector(vec[1])
	net.WriteVector(vec[2])
end


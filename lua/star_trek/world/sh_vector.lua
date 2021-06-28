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

-- Testing
BIG_SCALE = 8

-- Add the given Vector or World Vector to the World Vector
--
-- @param WorldVector a
-- @param WorldVector/Vector b
-- @return WorldVector result
local function __add(a, b)
	if isvector(b) then
		return WorldVector(a.Big, a.Small + b)
	end

	return WorldVector(a.Big + b.Big, a.Small + b.Small)
end

-- Substract the given Vector or World Vector from the World Vector
--
-- @param WorldVector a
-- @param WorldVector/Vector b
-- @return WorldVector result
local function __sub(a, b)
	if isvector(b) then
		return WorldVector(a.Big, a.Small - b)
	end

	return WorldVector(a.Big - b.Big, a.Small - b.Small)
end

-- Mutliplies a given vector with a scalar.
--
-- @param WorldVector a
-- @param Number b
-- @return WorldVector result
local function __mul(a, b)
	return WorldVector(a.Big * b, a.Small * b)
end

-- Divides a given vector by a scalar.
--
-- @param WorldVector a
-- @param Number b
-- @return WorldVector result
local function __div(a, b)
	return WorldVector(a.Big / b, a.Small / b)
end

-- Compares two vectors with each other for being the same.
--
-- @param WorldVector a
-- @param WorldVector b
-- @return Boolean equal
local function  __eq(a, b)
	return (a.Big == b.Big) and (a.Small == b.Small)
end

-- Converts the vector into a string, to be printed.
--
-- @param WorldVector a
-- @return Strint string
local function __tostring(a)
	return tostring(a.Big) .. " | " .. tostring(a.Small)
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
	local s = self.Small

	self.Small = Vector(
		s.x % BIG_SCALE,
		s.y % BIG_SCALE,
		s.z % BIG_SCALE
	)

	local temp = (s - self.Small) / 8
	self.Big = Vector(
		self.Big.x + math.floor(temp.x),
		self.Big.y + math.floor(temp.y),
		self.Big.z + math.floor(temp.z)
	)
end

function Star_Trek.World.Vector:ToVector()
	return self.Big * BIG_SCALE + self.Small
end

function Star_Trek.World.Vector:LengthSqr()
	local temp = self.Big * BIG_SCALE + self.Small
	return temp:LengthSqr()
end

function Star_Trek.World.Vector:Length()
	local temp = self.Big * BIG_SCALE + self.Small
	return temp:Length()
end
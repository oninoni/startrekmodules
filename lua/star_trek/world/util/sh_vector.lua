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
--       World Vector | Shared       --
---------------------------------------

-- Concept:
-- 2 Floats per Coordiate
-- Split at 1024*1024
-- plenty precision for ,... !
-- RANGE: (1024*1024*1024*1024*64) * (1024*1024), (1024 * 1024 * 1024 * 64)

-- Split Value is set here:
local MAX_SMALL_VALUE = 1024 * 1024

local vectorMeta = {}
vectorMeta.IsWorldVector = true
Star_Trek.World.Vector = vectorMeta

function IsWorldVector(a)
	if a.IsWorldVector then
		return true
	end

	return false
end

-- Negates WorldVector and returns the result.
--
-- @param WorldVector a
-- @return WorldVector result
local function __unm(a)
	return WorldVector(
		-a[1],
		-a[2],
		-a[3],
		-a[4],
		-a[5],
		-a[6]
	)
end

-- Adds the given Vector or WorldVector to the WorldVector and returns the result.
--
-- @param WorldVector a
-- @param WorldVector/Vector b
-- @return WorldVector result
local function __add(a, b)
	if isvector(b) then
		return WorldVector(
			a[1], a[2], a[3],
			a[4] + b.x,
			a[5] + b.y,
			a[6] + b.z
		)
	end

	if IsWorldVector(b) then
		return WorldVector(
			a[1] + b[1],
			a[2] + b[2],
			a[3] + b[3],
			a[4] + b[4],
			a[5] + b[5],
			a[6] + b[6]
		)
	end

	error("Adding World Vectors: vector expected got " .. type(b))
end

-- Substracts the given Vector or WorldVector to the WorldVector and returns the result.
--
-- @param WorldVector a
-- @param WorldVector/Vector b
-- @return WorldVector result
local function __sub(a, b)
	if isvector(b) then
		return WorldVector(
			a[1], a[2], a[3],
			a[4] - b.x,
			a[5] - b.y,
			a[6] - b.z
		)
	end

	if IsWorldVector(b) then
		return WorldVector(
			a[1] - b[1],
			a[2] - b[2],
			a[3] - b[3],
			a[4] - b[4],
			a[5] - b[5],
			a[6] - b[6]
		)
	end

	error("Substracting World Vectors: vector expected got " .. type(b))
end

-- Mutliplies a given vector with a scalar and returns the result.
--
-- @param WorldVector a
-- @param Number b
-- @return WorldVector result
local function __mul(a, b)
	if isnumber(b) then
		return WorldVector(
			a[1] * b,
			a[2] * b,
			a[3] * b,
			a[4] * b,
			a[5] * b,
			a[6] * b
		)
	end

	error("Scaling World Vectors: number expected got" .. type(b))
end

-- Divides a given vector with a scalar and returns the result.
--
-- @param WorldVector a
-- @param Number b
-- @return WorldVector result
local function __div(a, b)
	if isnumber(b) then
		return WorldVector(
			a[1] / b,
			a[2] / b,
			a[3] / b,
			a[4] / b,
			a[5] / b,
			a[6] / b
		)
	end

	error("Division Scaling World Vectors: number expected got" .. type(b))
end

-- Compares two vectors with each other for being the same.
--
-- @param WorldVector a
-- @param WorldVector b
-- @return Boolean equal
local function __eq(a, b)
	if isnumber(b) then
		if  a[1] == b[1]
		and a[2] == b[2]
		and a[3] == b[3]
		and a[4] == b[4]
		and a[5] == b[5]
		and a[6] == b[6] then
			return true
		end

		return false
	end

	error("Comparing World Vectors: world vector expected got" .. type(b))
end

-- Converts the vector into a string, to be output.
--
-- @param WorldVector a
-- @return Strint string
local function __tostring(a)
	return "[B " .. a[1] .. " " .. a[2] .. " " .. a[3] .. " |S " .. a[4] .. " " .. a[5] .. " " .. a[6] .. " ]"
end

-- Define the Meta Table here. Optimisation!
local metaTable = {
	__index = vectorMeta,
	__unm = __unm, -- -(a)
	__add = __add, -- a + b
	__sub = __sub, -- a - b
	__mul = __mul, -- a * b
	__div = __div, -- a / b
	__eq  =  __eq, -- a == b
	__tostring = __tostring,
}

-- Create a World Vector and return it.
--
-- @param number bx
-- @param number by
-- @param number bz
-- @param number sx
-- @param number sy
-- @param number sz
-- @return WorldVector worldVector
function WorldVector(bx, by, bz, sx, sy, sz)
	local worldVector = {
		[1] = bx,
		[2] = by,
		[3] = bz,
		[4] = sx,
		[5] = sy,
		[6] = sz,
	}

	setmetatable(worldVector, metaTable)
	worldVector:FixValue()

	return worldVector
end

-- Reduces the Value to its minimum "Small" Vector Size.
-- Should be called after any operation.
function vectorMeta:FixValue()
	if 	self[4] <= MAX_SMALL_VALUE and self[4] > 0
	and self[5] <= MAX_SMALL_VALUE and self[5] > 0
	and self[6] <= MAX_SMALL_VALUE and self[6] > 0 then
		return
	end

	local x = self[4] % MAX_SMALL_VALUE
	self[1] = math.floor(self[1] + (self[4] - x) / MAX_SMALL_VALUE)
	self[4] = x

	local y = self[5] % MAX_SMALL_VALUE
	self[2] = math.floor(self[2] + (self[5] - y) / MAX_SMALL_VALUE)
	self[5] = y

	local z = self[6] % MAX_SMALL_VALUE
	self[3] = math.floor(self[3] + (self[6] - z) / MAX_SMALL_VALUE)
	self[6] = z
end

-- Returns a normal Vector from the worldVector.
-- WARNING: This can cause a loss of precision!
--
-- @return Vector result
function vectorMeta:ToVector()
	return Vector(
		self[1] * MAX_SMALL_VALUE + self[4],
		self[2] * MAX_SMALL_VALUE + self[5],
		self[3] * MAX_SMALL_VALUE + self[6]
	)
end

-- Returns the squared length of the world vector.
-- WARNING: This can cause a loss of precision!
--
-- @return Number lengthSqr
function vectorMeta:LengthSqr()
	local temp = self:ToVector()
	return temp:LengthSqr()
end

-- Returns the length of the world vector.
-- WARNING: This can cause a loss of precision!
--
-- @return Number length
function vectorMeta:Length()
	local temp = self:ToVector()
	return temp:Length()
end





function WorldToLocalBig(pos, ang, newSystemOrigin, newSystemAngles)
	local offsetPos = pos - newSystemOrigin

	return WorldToLocal(offsetPos:ToVector(), ang, Vector(), newSystemAngles)
end

function net.ReadWorldVector()
	local bx = net.ReadDouble()
	local by = net.ReadDouble()
	local bz = net.ReadDouble()
	local sx = net.ReadDouble()
	local sy = net.ReadDouble()
	local sz = net.ReadDouble()

	return WorldVector(bx, by, bz, sx, sy, sz)
end

function net.WriteWorldVector(worldVector)
	net.WriteDouble(worldVector[1])
	net.WriteDouble(worldVector[2])
	net.WriteDouble(worldVector[3])
	net.WriteDouble(worldVector[4])
	net.WriteDouble(worldVector[5])
	net.WriteDouble(worldVector[6])
end
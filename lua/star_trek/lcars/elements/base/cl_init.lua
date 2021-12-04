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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--    LCARS Base Element | Client    --
---------------------------------------

if not istable(ELEMENT) then Star_Trek:LoadAllModules() return end
local SELF = ELEMENT

SELF.BaseElement = nil

SELF.Variants = 1

-- Filter a value to be of the next power of 2.
-- 
-- @param value
-- @return filteredValue
function SELF:FilterSize(value)
	return 2 ^ math.ceil(math.log(value) / math.log(2))
end

-- Draw a given Variant of the element.
--
-- @param Number x
-- @param Number y
-- @param Number i
function SELF:DrawElement(i, x, y)
end

-- Draw the actual element.
function SELF:Draw()
	render.Clear(0, 0, 0, 0, true, true)

	for i = 1, self.Variants do
		local y = self.ElementHeight * (i - 1)
		self:DrawElement(i, 0, y)
	end
end

-- Generate the element and prepare material / texture.
function SELF:Initialize()
	local width = self.ElementWidth
	local height = self.ElementHeight

	self.Width = self:FilterSize(width)
	self.Height = self:FilterSize(height * self.Variants)

	self.Name = "LCARS_" .. self.Id .. "_" .. self.Width .. "_" .. self.Height
	self.Texture = GetRenderTarget(self.Name, self.Width, self.Height)
	self.Material = CreateMaterial(self.Name, "UnlitGeneric", {
		["$basetexture"] = self.Texture:GetName(),
		["$translucent"] = 1,
		["$vertexalpha"] = 1
	})

	self.U = width / self.Width
	self.V = height / self.Height
end

function SELF:GetVariant()
	return 1
end

-- Render the element.
--
-- @param Number x
-- @param Number y
function SELF:Render(x, y)
	local i = self:GetVariant()

	surface.SetMaterial(self.Material)

	surface.DrawTexturedRectUV(
		x,
		y,
		self.ElementWidth,
		self.ElementHeight,
		0,
		self.V * (i - 1),
		self.U,
		self.V * i
	)
end
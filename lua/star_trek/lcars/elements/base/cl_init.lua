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
--    Copyright © 2022 Jan Ziegler   --
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
		local y = (self.ElementHeight + 1) * (i - 1)

		self:DrawElement(i, 0, y)
	end
end

-- Generate the texture.
function SELF:GenerateTexture()
	local width = self.ElementWidth
	local height = self.ElementHeight + 1

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
	self.V1 = height / self.Height
	self.V2 = (height - 1) / self.Height

	local oldW, oldH = ScrW(), ScrH()
	render.SetViewPort(0, 0, self.Width, self.Height)

	render.PushRenderTarget(self.Texture)
	cam.Start2D()
		self:Draw()
	cam.End2D()
	render.PopRenderTarget()

	render.SetViewPort(0, 0, oldW, oldH)
end

-- Style Changing function to be overridden.
--
-- @param String style
function SELF:ApplyStyle()
end

-- Generate the element and prepare material / texture.
function SELF:Initialize()
	self:ApplyStyle()

	self.LifeTime = 0
end

-- Function, that allows you to set the current style of the menu.
-- 
-- @param String style
function SELF:SetStyle(style)
	if self.CurrentStyle == style then
		return
	end

	self.CurrentStyle = style

	self:ApplyStyle()
	self:GenerateTexture()
end

-- Think hook.
function SELF:OnThink()
	self.LifeTime = self.LifeTime + FrameTime()
end

-- Return the current variant of the object.
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

	local v = self.V1 * (i - 1)
	surface.DrawTexturedRectUV(
		x,
		y,
		self.ElementWidth,
		self.ElementHeight,
		0,
		v,
		self.U,
		v + self.V2
	)
end
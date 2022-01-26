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
--     Transporter Cycle | Color     --
---------------------------------------

if not istable(CYCLE) then Star_Trek:LoadAllModules() return end
local SELF = CYCLE

-- Reset the color of a given entity.
--
-- @param Entity ent
function SELF:ResetColor(ent)
	local resetColor = ent.TransporterResetColor
	if resetColor then
		ent:SetColor(resetColor)
	end
end

-- Stores the color of a given entity.
--
-- @param Entity ent
function SELF:ApplyColor(ent)
	self:ResetColor(ent)

	local color = ent:GetColor()
	ent.TransporterResetColor = Color(color.r, color.g, color.b, color.a)
end

-- Draws the alpha faded color of a given entity.
--
-- @param Entity ent
-- @param Number alpha
function SELF:RenderColor(ent, alpha)
	ent:SetColor(ColorAlpha(ent.TransporterResetColor or Color(), alpha))
end

-- Reset the color of the main entity and it's children.
function SELF:ResetColors()
	local ent = self.Entity

	self:ResetColor(ent)

	for _, child in pairs(ent:GetChildren()) do
		self:ResetColor(child)
	end
end

-- Stores the color of the main entity and it's children.
function SELF:ApplyColors()
	local ent = self.Entity

	self:ApplyColor(ent)

	for _, child in pairs(ent:GetChildren()) do
		self:ApplyColor(child)
	end
end

-- Stores the color of the main entity and it's children.
function SELF:RenderColors(alpha)
	local ent = self.Entity

	self:RenderColor(ent, alpha)

	for _, child in pairs(ent:GetChildren()) do
		self:RenderColor(child, alpha)
	end
end
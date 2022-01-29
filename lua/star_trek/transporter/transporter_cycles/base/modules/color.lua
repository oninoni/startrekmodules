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
		ent.TransporterResetColor = nil
	end
end

-- Stores the color of a given entity.
--
-- @param Entity ent
function SELF:ApplyColor(ent, alpha)
	local color = ent:GetColor()
	ent.TransporterResetColor = Color(color.r, color.g, color.b, color.a)

	if isnumber(alpha) then
		print("Restored to", alpha)
		ent:SetColor(ColorAlpha(ent.TransporterResetColor or color_white, alpha))
	end
end

-- Draws the alpha faded color of a given entity.
--
-- @param Entity ent
-- @param Number alpha
function SELF:RenderColor(ent, alpha)
	ent:SetColor(ColorAlpha(ent.TransporterResetColor or color_white, alpha))
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

	-- Get Color of "End of previous Phaser"
	-- Used for quick restoration of state.

	local targetAlpha
	local lastState = self.State - 1
	local lastStateData = self.States[lastState]
	if istable(lastStateData) then
		local lastColorFade = lastStateData.ColorFade
		if isnumber(lastColorFade) then
			if lastColorFade > 0 then
				targetAlpha = 0
			else
				targetAlpha = 255
			end
		end
	end

	self:ApplyColor(ent, targetAlpha)

	for _, child in pairs(ent:GetChildren()) do
		self:ApplyColor(child, targetAlpha)
	end
end

-- Stores the color of the main entity and it's children.
function SELF:RenderColors(duration, colorFade)
	local diff = CurTime() - self.StateTime
	local fade = math.max(0, math.min(diff / duration, 1))

	local alpha
	if colorFade > 0 then
		alpha = 255 * (1 - fade)
	else
		alpha = 255 * fade
	end

	print(alpha)

	local ent = self.Entity

	self:RenderColor(ent, alpha)

	for _, child in pairs(ent:GetChildren()) do
		self:RenderColor(child, alpha)
	end
end
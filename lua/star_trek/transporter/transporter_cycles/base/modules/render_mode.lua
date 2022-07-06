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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--  Transporter Cycle | Render Mode  --
---------------------------------------

if not istable(CYCLE) then Star_Trek:LoadAllModules() return end
local SELF = CYCLE

-- Reset the render mode of a given entity.
--
-- @param Entity ent
function SELF:ResetRenderMode(ent)
	local resetRenderMode = ent.TransporterResetRenderMode
	if resetRenderMode then
		ent:SetRenderMode(resetRenderMode)
		ent.TransporterResetRenderMode = nil
	end
end

-- Set the render mode of a given entity.
--
-- @param Entity ent
-- @param Number renderMode
function SELF:ApplyRenderMode(ent, renderMode)
	self:ResetRenderMode(ent)

	ent.TransporterResetRenderMode = ent:GetRenderMode()
	ent:SetRenderMode(renderMode)
end

-- Reset the render mode of the main entity and it's children.
function SELF:ResetRenderModes()
	local ent = self.Entity

	self:ResetRenderMode(ent)

	for _, child in pairs(ent:GetChildren()) do
		self:ResetRenderMode(child)
	end
end

-- Set the render mode of the main entity and it's children.
--
-- @param Number renderMode
function SELF:ApplyRenderModes(renderMode)
	local ent = self.Entity

	self:ApplyRenderMode(ent, renderMode)

	for _, child in pairs(ent:GetChildren()) do
		self:ApplyRenderMode(child, renderMode)
	end
end
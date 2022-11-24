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
--     Federation Cycle | Client     --
---------------------------------------

if not istable(CYCLE) then Star_Trek:LoadAllModules() return end
local SELF = CYCLE

-- Initializes the transporter cycle.
--
-- @param Entity ent
function SELF:Initialize()
	SELF.Base.Initialize(self)

	local ent = self.Entity

	local low, high = ent:GetCollisionBounds()
	local objectWidth = (high[1] - low[1]) + (high[2] - low[2]) / 2

	self.FlareRight = ent:GetRight() * objectWidth * 0.25
	self.FlareForward = ent:GetForward() * objectWidth * 0.25

	self.FlareSize = self.ObjectSize * 3
	self.FlareSizeSmall = self.FlareSize * 0.8
end

-- Applies the current state to the transporter cycle.
--
-- @param Number state
-- @param Boolean onlyRestore
function SELF:ApplyState(state, onlyRestore)
	SELF.Base.ApplyState(self, state, onlyRestore)
end

-- Renders the effects of the transporter cycle.
function SELF:Render()
	SELF.Base.Render(self)

	local stateData = self:GetStateData()
	if not istable(stateData) then return end

	local ent = self.Entity

	local diff = CurTime() - self.StateTime

	local pos = ent:GetPos() + self.Offset

	local effectProgress1 = math.max(0, math.min(diff * 0.5, 1)) -- TODO Rebalance values

	local alpha1 = (0.5 - math.abs(effectProgress1 - 0.5))
	alpha1 = math.min(alpha1, 0.2) * 1.5

	local effectProgress1Slope = 1 - (math.cos(effectProgress1 * math.pi) + 1) / 2

	local vec = EyeVector()
	vec[3] = 0

	local mat = Material("oninoni/startrek/flare_red_vertical")
	render.SetMaterial(mat)

	local flareRight = self.FlareRight
	local flareForward = self.FlareForward

	local size = self.FlareSize
	local smallSize = self.FlareSizeSmall

	local offset = Vector(0, 0, 0.3)
	local c = Color(0, 0, 0, 0)

	mat:SetVector( "$alpha", Vector(alpha1, 0, 0))
	render.DrawQuadEasy(pos -  flareRight * effectProgress1Slope,           vec, size     , size     , c)
	render.DrawQuadEasy(pos +  flareRight * effectProgress1Slope,           vec, size     , size     , c)
	render.DrawQuadEasy(pos - (flareRight * effectProgress1Slope + offset), vec, smallSize, smallSize, c)
	render.DrawQuadEasy(pos + (flareRight * effectProgress1Slope + offset), vec, smallSize, smallSize, c)

	render.DrawQuadEasy(pos -  flareForward * effectProgress1Slope,           vec, size     , size     , c)
	render.DrawQuadEasy(pos +  flareForward * effectProgress1Slope,           vec, size     , size     , c)
	render.DrawQuadEasy(pos - (flareForward * effectProgress1Slope + offset), vec, smallSize, smallSize, c)
	render.DrawQuadEasy(pos + (flareForward * effectProgress1Slope + offset), vec, smallSize, smallSize, c)
end
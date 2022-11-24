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

	local up = ent:GetUp()
	if ent:IsPlayer() then
		up = Vector(0, 0, 1)
	end

	local low, high = ent:GetCollisionBounds()
	local objectHeight = high[3] - low[3]

	self.FlareUpHeight = up * objectHeight * 0.5
	self.FlareSize = self.ObjectSize * 6
	self.FlareSizeSmall = self.FlareSize * 0.3
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

	local effectProgress1 = math.max(0, math.min(diff * 0.7 - 0.3, 1)) -- TODO Rebalance values
	local effectProgress2 = math.max(0, math.min(diff * 0.7      , 1)) -- TODO Rebalance values

	local alpha1 = (0.5 - math.abs(effectProgress1 - 0.5))
	alpha1 = math.min(alpha1, 0.2) * 1.5
	local alpha2 = (0.5 - math.abs(effectProgress2 - 0.5))
	alpha2 = math.min(alpha2, 0.2) * 1.5

	local effectProgress1Slope = 1 - (math.cos(effectProgress1 * math.pi) + 1) / 2
	local effectProgress2Slope = 1 - (math.cos(effectProgress2 * math.pi) + 1) / 2

	local vec = EyeVector()
	vec[3] = 0

	local mat = Material("oninoni/startrek/flare_blue")
	render.SetMaterial(mat)

	local upHeight = self.FlareUpHeight
	local size = self.FlareSize
	local smallSize = self.FlareSizeSmall

	local offset = Vector(0, 0, 0.3)
	local c = Color(0, 0, 0, 0)

	mat:SetVector( "$alpha", Vector(alpha1, 0, 0))
	render.DrawQuadEasy(pos -  upHeight * effectProgress1Slope,           vec, size     , size     , c)
	render.DrawQuadEasy(pos +  upHeight * effectProgress1Slope,           vec, size     , size     , c)
	render.DrawQuadEasy(pos - (upHeight * effectProgress1Slope + offset), vec, smallSize, smallSize, c)
	render.DrawQuadEasy(pos + (upHeight * effectProgress1Slope + offset), vec, smallSize, smallSize, c)

	mat:SetVector( "$alpha", Vector(alpha2, 0, 0))
	render.DrawQuadEasy(pos -  upHeight * effectProgress2Slope,           vec, size     , size     , c)
	render.DrawQuadEasy(pos +  upHeight * effectProgress2Slope,           vec, size     , size     , c)
	render.DrawQuadEasy(pos - (upHeight * effectProgress2Slope + offset), vec, smallSize, smallSize, c)
	render.DrawQuadEasy(pos + (upHeight * effectProgress2Slope + offset), vec, smallSize, smallSize, c)
end
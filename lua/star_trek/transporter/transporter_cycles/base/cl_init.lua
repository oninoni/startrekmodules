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
--  Base Transporter Cycle | Client  --
---------------------------------------

if not istable(CYCLE) then Star_Trek:LoadAllModules() return end
local SELF = CYCLE

-- Initializes the transporter cycle.
--
-- @param Entity ent
function SELF:Initialize()
	local ent = self.Entity

	if ent == LocalPlayer() then
		Star_Trek.Transporter.LocalCycle = self

		local offset = ent:WorldToLocal(ent:EyePos())
		self.BufferEyePos = LocalToWorld(offset, Angle(), self.BufferPos, ent:GetAngles())

		self.RT1 = GetRenderTarget("TransporterFadeRT1", ScrW(), ScrH())
		self.RT2 = GetRenderTarget("TransporterFadeRT2", ScrW(), ScrH()) -- TODO: Check if disable alpha true, false works
		self.RTMaterial = CreateMaterial("TransporterFade", "UnlitGeneric", {
			["$basetexture"] = self.RT2:GetName(),
			["$vertexalpha"] = "1",
			["$vertexcolor"] = "1",
		})
	end

	-- Detect Size, for effect to use.
	local low, high = ent:GetCollisionBounds()
	local xSize = high[1] - low[1]
	local ySize = high[2] - low[2]
	self.ObjectSize = (xSize + ySize) / 2
	self.ObjectHeight = high[3] - low[3]
	local offset = high[3] + low[3]
	self.Offset = Vector(0, 0, offset / 2)

	self.State = 1
	if self.SkipDemat then
		self.State = self.SkipDematState
		for state = 1, self.State - 1 do
			self:ApplyState(state)
		end
	end
end

function SELF:ResetParticleEffect()
end

function SELF:End()
	if Star_Trek.Transporter.LocalCycle == self then
		Star_Trek.Transporter.LocalCycle = nil
	end

	local stateData = self:GetStateData()
	if istable(stateData) then return end

	local ent = self.Entity
	if IsValid(ent) then
		self:ResetRenderModes()
		self:ResetColors()

		self:ResetParticleSystems()
	end
end

-- Applies the current state to the transporter cycle.
--
-- @param Number state
function SELF:ApplyState(state)
	self.State = state
	self.StateTime = CurTime()

	local stateData = self:GetStateData()
	if not istable(stateData) then return end

	local ent = self.Entity

	local renderMode = stateData.RenderMode
	if renderMode ~= nil then
		self:ApplyRenderModes(renderMode)
	end

	local colorFade = stateData.ColorFade
	if isnumber(colorFade) then
		self:ApplyColors()
	end

	self:ResetParticleSystems()

	local particleName = stateData.ParticleName
	if isstring(particleName) then
		self:ApplyParticleSystems(particleName, ent:GetPos() + self.Offset)
	end
end

-- Renders the effects of the transporter cycle.
function SELF:Render()
	local stateData = self:GetStateData()
	if not istable(stateData) then return end

	local colorFade = stateData.ColorFade
	if isnumber(colorFade) then
		local diff = CurTime() - self.StateTime
		local fade = math.max(0, math.min(diff / stateData.Duration, 1))

		local alpha
		if colorFade > 0 then
			alpha = 255 * (1 - fade)
		else
			alpha = 255 * fade
		end

		self:RenderColors(alpha)
	end
end

-- Renders the screenspace effects of the transporter cycle when the local player is being transported.
function SELF:RenderScreenspaceEffect()
	local diff = CurTime() - self.StateTime

	local stateData = self:GetStateData()
	if not istable(stateData) then return end

	local colorFade = stateData.ColorFade
	if colorFade == nil then return end

	render.PushRenderTarget(self.RT1)
		render.Clear(0,0,0,255)

		render.RenderView( {
			origin = self.BufferEyePos,
			drawviewmodel = false,
		})
	render.PopRenderTarget()

	local fade
	if colorFade > 0 then
		fade = math.min(1, diff / stateData.Duration)
	else
		fade = math.max(0, 1 - diff / stateData.Duration)
	end

	-- Push RT into new texture, to delete alpha values (WTF Man Garry. What is this???)
	-- TODO: Check if disable alpha true, false works
	render.PushRenderTarget(self.RT2)
		render.DrawTextureToScreen(self.RT1)
	render.PopRenderTarget()

	surface.SetDrawColor(255, 255, 255, 255 * fade) -- TODO Rebalance values + minmax
	surface.SetMaterial(self.RTMaterial)
	surface.DrawTexturedRect(-1, -1, ScrW() + 1, ScrH() + 1)

	DrawMaterialOverlay("effects/water_warp01", 0.1 * fade) -- TODO Rebalance values + minmax
end
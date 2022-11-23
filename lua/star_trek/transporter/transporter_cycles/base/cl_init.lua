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

		if self.BufferPos == Vector() then
			self.OverrideBuffer = true
		end

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
	local offset = high[3] + low[3]
	self.Offset = Vector(0, 0, offset / 2)

	self.State = 1
	if self.SkipDemat then
		for state = 1, self.SkipDematState - 1 do
			self:ApplyState(state, true)
		end

		self.State = self.SkipDematState
	end
end

function SELF:ResetParticleEffect()
end

function SELF:End()
	if Star_Trek.Transporter.LocalCycle == self then
		Star_Trek.Transporter.LocalCycle = nil
	end

	local ent = self.Entity
	if IsValid(ent) then
		self:ResetParticleSystems()

		local stateData = self:GetStateData()
		if istable(stateData) then return end

		self:ResetRenderModes()
		self:ResetColors()
	end
end

-- Applies the current state to the transporter cycle.
--
-- @param Number state
-- @param Boolean onlyRestore
function SELF:ApplyState(state, onlyRestore)
	self.State = state
	self.StateTime = CurTime()

	local stateData = self:GetStateData()
	if not istable(stateData) then return end

	local ent = self.Entity

	local renderMode = stateData.RenderMode
	if renderMode ~= nil then
		self:ApplyRenderModes(renderMode)
	end

	self:ApplyColors()

	if onlyRestore then return end

	local soundName = stateData.SoundName
	if soundName then
		if Star_Trek.Transporter.LocalCycle == self then
			self.Entity:EmitSound(soundName, 20, 100, 0.5)
		else
			if stateData.PlaySoundAtTarget then
				sound.Play(soundName, self.TargetPos, 20, 100, 0.5)
			else
				sound.Play(soundName, ent:GetPos(), 20, 100, 0.5)
			end
		end
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
		self:RenderColors(stateData.Duration, colorFade, stateData.ColorTint)
	end
end

-- Renders the screenspace effects of the transporter cycle when the local player is being transported.
function SELF:RenderScreenspaceEffect()
	local diff = CurTime() - self.StateTime

	local stateData = self:GetStateData()
	if not istable(stateData) then return end

	if self.OverrideBuffer and stateData.TPToBuffer then
		local color = self.BufferColor or Color(255, 255, 255)
		render.Clear(color.r, color.g, color.b, 255)
	end

	local colorFade = stateData.ColorFade

	render.PushRenderTarget(self.RT1)
		render.Clear(0,0,0,255)

		if self.OverrideBuffer then
			local color = self.BufferColor or Color(255, 255, 255)
			render.Clear(color.r, color.g, color.b, 255)
		else
			render.RenderView( {
				origin = self.BufferEyePos,
				drawviewmodel = false,
			})
		end

	render.PopRenderTarget()

	local fade
	if stateData.TPToBuffer then
		fade = 1
	elseif colorFade > 0 then
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
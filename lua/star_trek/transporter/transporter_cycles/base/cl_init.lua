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
	self.State = 1
	if self.SkipDemat then
		self.State = self.SkipDematState
	end

	local ent = self.Entity

	if ent == LocalPlayer() then
		Star_Trek.Transporter.LocalCycle = self
		
		local offset = ent:WorldToLocal(ent:EyePos())
		self.TargetEyePos = LocalToWorld(offset, Angle(), self.TargetPos, ent:GetAngles())

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

	local up = ent:GetUp()
	if ent:IsPlayer() then
		up = Vector(0, 0, 1)
	end

	self.FlareUpHeight = up * self.ObjectHeight * 0.5
	self.FlareSize = self.ObjectSize * 6
	self.FlareSizeSmall = self.FlareSize * 0.3
end

function SELF:ResetRenderMode()
	local ent = self.Entity

	local defaultRenderMode = ent.TransporterDefaultRenderMode
	if defaultRenderMode == nil then
		defaultRenderMode = RENDERMODE_NORMAL
	end

	ent:SetRenderMode(defaultRenderMode)
end

function SELF:ResetColor()
	local ent = self.Entity

	local defaultColor = ent.TransporterDefaultColor
	if defaultColor == nil then
		defaultColor = Color(255, 255, 255, 255)
	end

	ent:SetColor(defaultColor)
end

function SELF:End()
	if Star_Trek.Transporter.LocalCycle == self then
		Star_Trek.Transporter.LocalCycle = nil
	end
	
	local ent = self.Entity
	if IsValid(ent) then
		self:ResetRenderMode()
		self:ResetColor()
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
		if renderMode == false then
			self:ResetRenderMode()
			ent.TransporterDefaultRenderMode = nil
		else
			ent.TransporterDefaultRenderMode = ent.TransporterDefaultRenderMode or ent:GetRenderMode()
			ent:SetRenderMode(renderMode)
		end
	end

	local colorFade = stateData.ColorFade
	if isnumber(colorFade) then
		if colorFade == 0 then
			self:ResetColor()
			ent.TransporterDefaultColor = nil
		else
			local color = ent:GetColor()
			ent.TransporterDefaultColor = ent.TransporterDefaultColor or Color(color.r, color.g, color.g, color.a)
		end
	end

	local particleName = stateData.ParticleName
	if isstring(particleName) then
		local partEffect = CreateParticleSystem(ent, particleName, PATTACH_ABSORIGIN_FOLLOW)
		partEffect:SetControlPoint(1, ent:GetPos() + self.Offset)
	end
end

-- Renders the effects of the transporter cycle.
function SELF:Render()
	local stateData = self:GetStateData()
	if not istable(stateData) then return end

	local ent = self.Entity

	local colorFade = stateData.ColorFade
	if isnumber(colorFade) then
		local diff = CurTime() - self.StateTime
	
		local fade = math.max(0, math.min(diff / 2, 1)) -- TODO Rebalance values
		
		if colorFade > 0 then
			ent:SetColor(ColorAlpha(ent.TransporterDefaultColor, 255 * (1 - fade)))
		else
			ent:SetColor(ColorAlpha(ent.TransporterDefaultColor, 255 * fade))
		end
	end
end

-- Renders the screenspace effects of the transporter cycle when the local player is being transported.
function SELF:RenderScreenspaceEffect()
	local diff = CurTime() - self.StateTime

	render.PushRenderTarget(self.RT1)
		render.Clear(0,0,0,255)

		render.RenderView( {
			origin = self.TargetEyePos,
			drawviewmodel = false,
		})
	render.PopRenderTarget()

	-- Push RT into new texture, to delete alpha values (WTF Man Garry. What is this???)
	-- TODO: Check if disable alpha true, false works
	render.PushRenderTarget(self.RT2)
		render.DrawTextureToScreen(self.RT1)
	render.PopRenderTarget()
	
	surface.SetDrawColor(255, 255, 255, 255 * diff) -- TODO Rebalance values + minmax
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(-1, -1, ScrW() + 1, ScrH() + 1)
	
	DrawMaterialOverlay("effects/water_warp01", diff * 0.1) -- TODO Rebalance values + minmax
end
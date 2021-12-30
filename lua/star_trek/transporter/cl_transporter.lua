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
--        Transporter | Client       --
---------------------------------------

Star_Trek.Transporter.ActiveTransports = Star_Trek.Transporter.ActiveTransports or {}

Star_Trek.Transporter.SelfActive = Star_Trek.Transporter.SelfActive or false
Star_Trek.Transporter.SelfRefrac = Star_Trek.Transporter.SelfRefrac or 0

function Star_Trek.Transporter:TriggerEffect(ent, remat, replicator)
	if not IsValid(ent) then return end

	local transportData = {
		Ent = ent,
		Remat = remat,
		AnimPos = 0,
		Replicator = replicator,
	}

	-- Save old Color, to be restored.
	transportData.OldColor = ent:GetColor()
	if ent.OldColor then
		transportData.OldColor = ent.OldColor
	end

	-- Detect Size, for effect to use.
	local low, high = ent:GetCollisionBounds()
	local width = high[1] - low[1]
	local depth = high[2] - low[2]
	transportData.ObjectSize = (width + depth) / 2
	transportData.ObjectHeight = high[3] - low[3]
	local offset = high[3] + low[3]
	transportData.Offset = offset / 2

	if remat then
		local partEffect = CreateParticleSystem(ent, "beam_in", PATTACH_ABSORIGIN_FOLLOW)
		partEffect:SetControlPoint(1, ent:GetPos() + Vector(0, 0, transportData.Offset))
	else
		local partEffect = CreateParticleSystem(ent, "beam_out", PATTACH_ABSORIGIN_FOLLOW)
		partEffect:SetControlPoint(1, ent:GetPos() + Vector(0, 0, transportData.Offset))
	end

	table.insert(self.ActiveTransports, transportData)
end

net.Receive("Star_Trek.Transporter.TriggerEffect", function()
	local ent = net.ReadEntity()
	local remat = net.ReadBool()
	local replicator = net.ReadBool()
	local targetPos = net.ReadVector()

	Star_Trek.Transporter:TriggerEffect(ent, remat, replicator)

	if ent == LocalPlayer() then
		local offset = ent:WorldToLocal(ent:EyePos())
		Star_Trek.Transporter.TargetPos = LocalToWorld(offset, Angle(), targetPos, ent:GetAngles())

		if not remat then
			Star_Trek.Transporter.SelfActive = true
			Star_Trek.Transporter.SelfRefrac = 0
		else
			Star_Trek.Transporter.SelfActive = false
			Star_Trek.Transporter.SelfRefrac = 1
		end
	end
end)

local rt = GetRenderTarget("TransporterFadeRT", ScrW(), ScrH())
local tex = GetRenderTarget("TransporterFadeTexture", ScrW(), ScrH())
local mat = CreateMaterial("TransporterFade", "UnlitGeneric", {
    ["$basetexture"] = tex:GetName(),
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
});

hook.Add("RenderScreenspaceEffects", "Star_Trek.Transporter.Effect", function()
	if Star_Trek.Transporter.SelfRefrac > 0 then
		render.PushRenderTarget(rt)
			render.Clear(0,0,0,255)

			render.RenderView( {
				origin = Star_Trek.Transporter.TargetPos,
				drawviewmodel = false,
			})
		render.PopRenderTarget()
		
		-- Push RT into new texture, to delete alpha values (WTF Man Garry. What is this???)
		render.PushRenderTarget(tex)
			render.DrawTextureToScreen(rt)
		render.PopRenderTarget()

		surface.SetDrawColor(255,255,255, 255 * Star_Trek.Transporter.SelfRefrac)
		surface.SetMaterial(mat)
		surface.DrawTexturedRect(-1, -1, ScrW()+1, ScrH()+1)
		
		DrawMaterialOverlay("effects/water_warp01", Star_Trek.Transporter.SelfRefrac * 0.1)
	end
end)

-- Shortcut function to draw the flares.
local function drawFlare(pos, vec, size)
	render.DrawQuadEasy(
		pos,
		vec,
		size,
		size,
		Color(0, 0, 0, 0),
		0
	)
end

local lastSysTime = SysTime()
hook.Add("PostDrawTranslucentRenderables", "Voyager.Transporter.MainRender", function()
	local vec = EyeVector()
	vec[3] = 0

	local frameTime = SysTime() - lastSysTime
	lastSysTime = SysTime()

	if Star_Trek.Transporter.SelfActive then
		Star_Trek.Transporter.SelfRefrac = math.min(1, Star_Trek.Transporter.SelfRefrac + 0.5 * frameTime)
	else
		Star_Trek.Transporter.SelfRefrac = math.max(0, Star_Trek.Transporter.SelfRefrac - 0.5 * frameTime)
	end

	local toBeRemoved = {}
	for _, transportData in pairs(Star_Trek.Transporter.ActiveTransports) do
		local ent = transportData.Ent
		if not IsValid(ent) then
			table.insert(toBeRemoved, transportData)
			continue
		end

		transportData.AnimPos = transportData.AnimPos + frameTime / 2

		local pos = ent:GetPos() + Vector(0, 0, transportData.Offset)
		local up = ent:GetUp()
		if ent:IsPlayer() then
			up = Vector(0, 0, 1)
		end

		local upHeight = up * transportData.ObjectHeight * 0.5

		local size = transportData.ObjectSize * 6
		local smallSize = size * 0.3

		local maxEffectProgress = math.max(0, math.min(transportData.AnimPos - 0.3, 1))
		local midEffectProgress = math.max(0, math.min(transportData.AnimPos      , 1))

		local maxAlpha = (0.5 - math.abs(maxEffectProgress - 0.5))
		maxAlpha = math.min(maxAlpha, 0.2) * 1.5
		local midAlpha = (0.5 - math.abs(midEffectProgress - 0.5))
		midAlpha = math.min(midAlpha, 0.2) * 1.5

		maxEffectProgress = (math.cos(maxEffectProgress * math.pi) + 1) / 2
		midEffectProgress = (math.cos(midEffectProgress * math.pi) + 1) / 2

		if transportData.Remat then
			maxEffectProgress = 1 - maxEffectProgress
			midEffectProgress = 1 - midEffectProgress

			ent:SetColor(ColorAlpha(transportData.OldColor, 255 * math.max(0, transportData.AnimPos - 0.3)))
		else
			ent:SetColor(ColorAlpha(transportData.OldColor, 255 - 255 * math.min(1, transportData.AnimPos - 0.3)))
		end

		if not transportData.Replicator then
			local mat = Material("oninoni/startrek/flare_blue")
			render.SetMaterial(mat)

			mat:SetVector( "$alpha", Vector(midAlpha, 0, 0))
			drawFlare(pos - upHeight * midEffectProgress, vec, size)
			drawFlare(pos + upHeight * midEffectProgress, vec, size)
			drawFlare(pos - (upHeight * midEffectProgress + Vector(0, 0, 0.3)), vec, smallSize)
			drawFlare(pos + (upHeight * midEffectProgress + Vector(0, 0, 0.3)), vec, smallSize)

			mat:SetVector( "$alpha", Vector(maxAlpha, 0, 0))
			drawFlare(pos - upHeight * maxEffectProgress, vec, size)
			drawFlare(pos + upHeight * maxEffectProgress, vec, size)
			drawFlare(pos - (upHeight * maxEffectProgress + Vector(0, 0, 0.3)), vec, smallSize)
			drawFlare(pos + (upHeight * maxEffectProgress + Vector(0, 0, 0.3)), vec, smallSize)
		end

		if transportData.AnimPos > 1.3 then
			table.insert(toBeRemoved, transportData)
		end
	end

	for _, transportData in pairs(toBeRemoved) do
		local ent = transportData.ent
		if IsValid(ent) then
			if transportData.Remat then
				ent:SetColor(ColorAlpha(transportData.OldColor, 255))
			else
				ent.OldColor = transportData.OldColor
			end
		end

		table.RemoveByValue(Star_Trek.Transporter.ActiveTransports, transportData)
	end
end)
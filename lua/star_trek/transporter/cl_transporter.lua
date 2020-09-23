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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--        Transporter | Client       --
---------------------------------------

Star_Trek.Transporter.ActiveTransports = Star_Trek.Transporter.ActiveTransports or {}

Star_Trek.Transporter.SelfActive = Star_Trek.Transporter.SelfActive or false
Star_Trek.Transporter.SelfRefrac = Star_Trek.Transporter.SelfRefrac or 0

function Star_Trek.Transporter:TriggerEffect(ent, remat)
    if ent == LocalPlayer() then
    end

    local transportData = {
        Ent = ent,
        Remat = remat,
        AnimPos = 0,
    }

    -- Save old Color, to be restored.
    transportData.OldColor = ent:GetColor()
    if ent.OldColor then
        transportData.OldColor = ent.OldColor
    end

    -- Detect Size, for effect to use.
    local low, high = ent:GetCollisionBounds()
    local width = high.x - low.x
    local depth = high.y - low.y
    transportData.ObjectSize = (width + depth) / 2
    transportData.ObjectHeight = high.z - low.z
    local offset = high.z + low.z
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

    Star_Trek.Transporter:TriggerEffect(ent, remat)
end)

net.Receive("Star_Trek.Transporter.TriggerPlayerEffect", function()
    local active = net.ReadBool()

    if active then
        Star_Trek.Transporter.SelfActive = true
        Star_Trek.Transporter.SelfRefrac = 0
    else
        Star_Trek.Transporter.SelfActive = false
        Star_Trek.Transporter.SelfRefrac = 255
    end
end)

local lastSysTime = SysTime()
-- First Effect for beaming yourself.
hook.Add("RenderScreenspaceEffects", "Star_Trek.Transporter.Effect", function()
    if Star_Trek.Transporter.SelfActive then
        DrawMaterialOverlay("effects/water_warp01", Star_Trek.Transporter.SelfActive)
        
        draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(31, 127, 255, Star_Trek.Transporter.SelfRefrac) )
    end
end)

hook.Add("PostDrawTranslucentRenderables", "Voyager.Transporter.MainRender", function()
    local vec = EyeVector()
    vec.z = 0

    local frameTime = SysTime() - lastSysTime
    lastSysTime = SysTime()

    if Star_Trek.Transporter.SelfActive then
        Star_Trek.Transporter.SelfRefrac = math.min(255, Star_Trek.Transporter.SelfRefrac + 100 * frameTime)
    else
        Star_Trek.Transporter.SelfRefrac = math.max(0, Star_Trek.Transporter.SelfRefrac - 100 * frameTime)
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

        cam.IgnoreZ(true)
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
        cam.IgnoreZ(false)
        
        local dLight = DynamicLight(ent:EntIndex(), false)
        if ( dLight ) then
            dLight.pos = ent:GetPos()
            dLight.r = 31
            dLight.g = 127
            dLight.b = 255
            dLight.brightness = 1
            dLight.Decay = 1000
            dLight.Size = 512 * (maxAlpha + midAlpha)
            dLight.DieTime = CurTime() + 1
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
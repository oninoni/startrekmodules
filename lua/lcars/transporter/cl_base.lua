

-- List of active Transports.
LCARS.ActiveTransports = LCARS.ActiveTransports or {}

-- Apply the transport Effect to the specified entity.
--
-- @param Entity ent
-- @param Boolean rematerialize
function LCARS:ApplyTransporter(ent, rematerialize)
    local transportData = {
        Object = ent,
        EffectProgress = 0,
        Rematerialize = rematerialize,
    }

    transportData.OldColor = ent:GetColor()
    if ent.OldColor then
        transportData.OldColor = ent.OldColor
    end

    local low, high = ent:GetCollisionBounds()
    transportData.ObjectHeight = high.z - low.z

    local width = high.x - low.x
    local depth = high.y - low.y
    transportData.ObjectSize = (width + depth) / 2

    local offset = high.z + low.z
    transportData.Offset = offset / 2

    if rematerialize then
        local partEffect = CreateParticleSystem(ent, "beam_in", PATTACH_ABSORIGIN_FOLLOW)
        partEffect:SetControlPoint(1, ent:GetPos() + Vector(0, 0, transportData.Offset))
    else
        local partEffect = CreateParticleSystem(ent, "beam_out", PATTACH_ABSORIGIN_FOLLOW)
        partEffect:SetControlPoint(1, ent:GetPos() + Vector(0, 0, transportData.Offset))
    end

    table.insert(self.ActiveTransports, transportData)
end

-- Network the transport effect.
net.Receive("LCARS.Tranporter.BeamObject", function()
    local ent = net.ReadEntity()
    local rematerialize = net.ReadBool()

    LCARS:ApplyTransporter(ent, rematerialize)
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
hook.Add("PostDrawTranslucentRenderables", "Voyager.Testing", function()
    local vec = EyeVector()
    vec.z = 0

    local frameTime = SysTime() - lastSysTime
    lastSysTime = SysTime()

    local toBeRemoved = {}
    for _, transportData in pairs(LCARS.ActiveTransports) do
        local ent = transportData.Object
        if not IsValid(ent) then
            table.insert(toBeRemoved, transportData)
            continue
        end
        
        transportData.EffectProgress = transportData.EffectProgress + frameTime / 2

        local pos = ent:GetPos() + Vector(0, 0, transportData.Offset)
        local up = ent:GetUp()
        if ent:IsPlayer() then
            up = Vector(0, 0, 1)
        end

        local upHeight = up * transportData.ObjectHeight * 0.5

        local size = transportData.ObjectSize * 6
        local smallSize = size * 0.3

        local maxEffectProgress = math.max(0, math.min(transportData.EffectProgress - 0.3, 1))
        local midEffectProgress = math.max(0, math.min(transportData.EffectProgress      , 1))
        
        local maxAlpha = (0.5 - math.abs(maxEffectProgress - 0.5))
        maxAlpha = math.min(maxAlpha, 0.2) * 1.5
        local midAlpha = (0.5 - math.abs(midEffectProgress - 0.5))
        midAlpha = math.min(midAlpha, 0.2) * 1.5

        maxEffectProgress = (math.cos(maxEffectProgress * math.pi) + 1) / 2
        midEffectProgress = (math.cos(midEffectProgress * math.pi) + 1) / 2

        if transportData.Rematerialize then
            maxEffectProgress = 1 - maxEffectProgress
            midEffectProgress = 1 - midEffectProgress
            
            ent:SetColor(ColorAlpha(transportData.OldColor, 255 * math.max(0, transportData.EffectProgress - 0.3)))
        else
            ent:SetColor(ColorAlpha(transportData.OldColor, 255 - 255 * math.min(1, transportData.EffectProgress - 0.3)))
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
            dLight.g = 63
            dLight.b = 255
            dLight.brightness = 1
            dLight.Decay = 1000
            dLight.Size = 512 * (maxAlpha + midAlpha)
            dLight.DieTime = CurTime() + 1
        end
        
        if transportData.EffectProgress > 1.3 then
            table.insert(toBeRemoved, transportData)
        end
    end

    for _, transportData in pairs(toBeRemoved) do
        local ent = transportData.Object
        if IsValid(ent) then
            if transportData.Rematerialize then
                ent:SetColor(ColorAlpha(transportData.OldColor, 255))
            else
                ent.OldColor = transportData.OldColor
            end
        end

        table.RemoveByValue(LCARS.ActiveTransports, transportData)
    end
end)
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
--           LCARS | Client          --
---------------------------------------

-- Marks the given interface, to be closed
--
-- @param Number id
function Star_Trek.LCARS:CloseInterface(id)
    if self.ActiveInterfaces[id] then
        self.ActiveInterfaces[id].Closing = true
    end
end

net.Receive("Star_Trek.LCARS.Close", function()
    local id = net.ReadInt(32)

    Star_Trek.LCARS:CloseInterface(id)
end)

function Star_Trek.LCARS:OpenMenu(id, interfaceData)
    local interface = {
        IPos = interfaceData.InterfacePos,
        IAng = interfaceData.InterfaceAngle,
        
        IVU = interfaceData.InterfaceAngle:Up(),
        IVR = interfaceData.InterfaceAngle:Right(),
        IVF = interfaceData.InterfaceAngle:Forward(),

        IVis = false,
        
        AnimPos = 0,
        Closing = false,

        Windows = {},
    }

    for i, windowData in pairs(interfaceData.Windows) do
        local windowFunctions = self.Windows[windowData.WindowType]
        if not istable(windowFunctions) then
            continue
        end

        local pos, ang = LocalToWorld(windowData.WindowPos, windowData.WindowAngles, interface.IPos, interface.IAng)

        local window = {
            WType = windowData.WindowType,

            WPos = pos,
            WAng = ang,
            
            WVis = false,
            
            WVU = ang:Up(),
            WVR = ang:Right(),
            WVF = ang:Forward(),

            WScale = windowData.WindowScale,
            WWidth = windowData.WindowWidth,
            WHeight = windowData.WindowHeight,
        }

        window = windowFunctions.OnCreate(window, windowData)
        if not istable(window) then
            continue
        end

        interface.Windows[i] = window
    end

    self.ActiveInterfaces[id] = interface
end

net.Receive("Star_Trek.LCARS.Open", function()
    local id = net.ReadInt(32)
    local interfaceData = net.ReadTable()

    Star_Trek.LCARS:OpenMenu(id, interfaceData)
end)

-- Returns the position of the mouse in the 2d plane of the window.
--
-- @param Table window
-- @param Vector eyePos
-- @param Vector eyeVector
-- @return Vector2D mousePos
function Star_Trek.LCARS:Get3D2DMousePos(window, eyePos, eyeVector)
    local pos = util.IntersectRayWithPlane(eyePos, eyeVector, window.WPos, window.WVU)
    pos = WorldToLocal(pos or Vector(), Angle(), window.WPos, window.WAng)

    return Vector(pos.x * window.WScale, pos.y * -window.WScale, 0)
end

-- Main Think Hook for all LCARS Screens
local lastThink = CurTime()
hook.Add("Think", "Star_Trek.LCARS.Think", function()
    local curTime = CurTime()
    local diff = curTime - lastThink

    local ply = LocalPlayer()
    local eyePos = ply:EyePos()

    local removeInterfaces = {}
    for i, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
        interface.IVis = false
        
        for _, window in pairs(interface.Windows) do
            local trace = util.TraceLine({
                start = eyePos,
                endpos = window.WPos,
                filter = ply
            })

            if trace.Hit then
                window.WVis = false
            else
                window.WVis = true
                interface.IVis = true
            end
        end

        if interface.Closing then
            interface.AnimPos = math.max(0, interface.AnimPos - diff * 2)

            if interface.AnimPos == 0 then
                table.insert(removeInterfaces, i)
            end
        else
            interface.AnimPos = math.min(1, interface.AnimPos + diff * 2)
        end
    end

    for _, i in pairs(removeInterfaces) do
        Star_Trek.LCARS.ActiveInterfaces[i] = nil
    end
    
    lastThink = curTime
end)

-- Main Render Hook for all LCARS Screens
hook.Add("PostDrawOpaqueRenderables", "Star_Trek.LCARS.Draw", function()
    local eyePos = LocalPlayer():EyePos()
    local eyeDir = EyeVector()

    for _, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
        if not interface.IVis then
            continue
        end

        for _, window in pairs(interface.Windows) do
            local width = window.WWidth
            local height = window.WHeight

            if not window.WVis then
                continue
            end

            cam.Start3D2D(window.WPos, window.WAng, 1 / window.WScale)
                local pos = Star_Trek.LCARS:Get3D2DMousePos(window, eyePos, eyeDir)

                if pos.x > -width / 2 and pos.x < width / 2
                and pos.y > -height / 2 and pos.y < height / 2 then
                    window.LastPos = pos
                end

                local windowFunctions = Star_Trek.LCARS.Windows[window.WType]
                if not istable(windowFunctions) then
                    continue
                end

                windowFunctions.OnDraw(window, window.LastPos or Vector(), interface.AnimPos)
            cam.End3D2D()
        end
    end
end)


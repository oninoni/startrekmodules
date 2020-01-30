

-- List of active Paneln.
-- Filled via Networking.
LCARS.ActivePanels = LCARS.ActivePanels or {}

-- List of Windows.
-- Will be filled by other files.
LCARS.Windows = LCARS.Windows or {}

-- Returns the position of the mouse in the 2d plane of the window.
--
-- @param Window window
-- @param Vector eyePos
-- @param Vector eyeVector
-- @return Vector mousePos
function LCARS:Get3D2DMousePos(window, eyePos, eyeVector)
    local pos = util.IntersectRayWithPlane(eyePos, eyeVector, window.CenterPos, window.Forward)
    pos = WorldToLocal(pos or Vector(), Angle(), window.CenterPos, window.Angles)

    return Vector(pos.x * window.Scale, pos.y * -window.Scale, 0)
end

-- Drawing a normal LCARS panel button. (2D Rendering Context)
--
-- @param Number x
-- @param Number y
-- @param Number width (min 300)
-- @param Text text
-- @param Color color
-- @param? Boolean selected
-- @param? String s
-- @param? String l
-- @param? Number alpha
function LCARS:DrawButton(x, y, width, text, color, selected, s, l, alpha)
    local lcars_white = Color(255, 255, 255, alpha)
    local lcars_black = Color(0, 0, 0, alpha)
    color = ColorAlpha(color, alpha)

    local widthDiff = math.max(0, width - 300)
    local widthOffset = widthDiff / 2

    draw.RoundedBox(16, -121 + x - widthOffset, y - 1, 242 + widthDiff, 32, selected and lcars_white or lcars_black)
    draw.RoundedBox(15, -120 + x - widthOffset, y, 240 + widthDiff, 30, color)
    draw.RoundedBox(0, -100 + x - widthOffset, y, 10, 30, lcars_black)
    draw.RoundedBox(0, 55 + x + widthOffset, y, 15, 30, lcars_black)
    draw.RoundedBox(0, 0 + x + widthOffset, y, 45, 30, lcars_black)

    if #s == 1 then
        draw.DrawText(s, "LCARSBig", 21 + x + widthOffset, y - 4, color, TEXT_ALIGN_LEFT)
    else
        draw.DrawText(s, "LCARSBig", 3 + x + widthOffset, y - 4, color, TEXT_ALIGN_LEFT)
    end

    draw.DrawText(text, "LCARSText", -88 + x - widthOffset, y + 14, lcars_black, TEXT_ALIGN_LEFT)
    draw.DrawText(l, "LCARSSmall", 71 + x + widthOffset, y + 18, lcars_black, TEXT_ALIGN_LEFT)
end

function LCARS:CloseMenu(id)
    if LCARS.ActivePanels[id] then
        LCARS.ActivePanels[id].Closing = true
    end
end

net.Receive("LCARS.Screens.CloseMenu", function()
    local id = net.ReadString()
    
    LCARS:CloseMenu(id)
end)

function LCARS:OpenMenu(id, panelData)
    local panel = {
        Visible = false,

        Scale = panelData.Scale or 20,

        MenuPos = 0,
        Closing = false,
    }

    panel.CenterPos = panelData.Pos
    if panelData.Angles then
        panel.Up = panelData.Angles:Up()
        panel.Right = panelData.Angles:Right()
        panel.Forward = panelData.Angles:Forward()
    else
        panel.Up = Vector(0, 0, 1)
        panel.Right = Vector(0, 1, 0)
        panel.Forward = Vector(1, 0, 0)
    end
    panel.Angles = panel.Right:AngleEx(panel.Right:Cross(panel.Up))

    panel.Windows = panelData.Windows or {}
    for _, window in pairs(panel.Windows) do
        window.Scale = window.Scale or panel.Scale
        
        window.Width = window.Width or 300
        window.Height = window.Height or 300
        
        window.CenterPos = window.Pos or panel.CenterPos
        if window.Angles then
            window.Up = window.Angles:Up()
            window.Right = window.Angles:Right()
            window.Forward = window.Angles:Forward()
        else
            window.Up = panel.Up
            window.Right = panel.Right
            window.Forward = panel.Forward
        end
        window.Angles = window.Right:AngleEx(window.Right:Cross(window.Up))

        window.LastPos = Vector()
    end

    LCARS.ActivePanels[id] = panel
end

net.Receive("LCARS.Screens.OpenMenu", function()
    local id = net.ReadString()
    local panelData = net.ReadTable()

    LCARS:OpenMenu(id, panelData)
end)

function LCARS:UpdateWindow(id, windowId, window)
    local panel = LCARS.ActivePanels[id]
    if not istable(panel) then return end
    
    window.Scale = window.Scale or panel.Scale
    
    window.Width = window.Width or 300
    window.Height = window.Height or 300
    
    window.CenterPos = window.Pos or panel.CenterPos
    if window.Angles then
        window.Up = window.Angles:Up()
        window.Right = window.Angles:Right()
        window.Forward = window.Angles:Forward()
    else
        window.Up = panel.Up
        window.Right = panel.Right
        window.Forward = panel.Forward
    end
    window.Angles = window.Right:AngleEx(window.Right:Cross(window.Up))

    window.LastPos = Vector()

    panel.Windows[windowId] = window
end

net.Receive("LCARS.Screens.UpdateWindow", function()
    local id = net.ReadString()
    local windowId = net.ReadInt(32)
    local window = net.ReadTable()

    LCARS:UpdateWindow(id, windowId, window)
end)

local lastThink = CurTime()

-- Main Think Hook for all LCARS Screens
hook.Add("Think", "LCARS.Screens.Think", function()
    local diffTime = CurTime() - lastThink
    local eyePos = LocalPlayer():EyePos()

    local toBeRemoved = {}
    for panelId, panel in pairs(LCARS.ActivePanels) do
        local trace = util.TraceLine({
            start = eyePos,
            endpos = panel.CenterPos,
            filter = LocalPlayer()
        })

        if trace.Hit then
            panel.Visible = false
        else
            panel.Visible = true
        end
        
        if panel.Closing then
            panel.MenuPos = math.max(0, panel.MenuPos - diffTime * 2)

            if panel.MenuPos == 0 then
                table.insert(toBeRemoved, panelId)
            end
        else
            panel.MenuPos = math.min(1, panel.MenuPos + diffTime * 2)
        end
    end
    
    for _, panelId in pairs(toBeRemoved) do
        LCARS.ActivePanels[panelId] = nil
    end

    lastThink = CurTime()
end)

-- Recording interact presses and checking interaction with panel
hook.Add("KeyPress", "LCARS.Screens.KeyPress", function(ply, key)
    local eyePos = LocalPlayer():EyePos()
    local eyeVector = EyeVector()

    if key ~= IN_USE and key ~= IN_ATTACK then return end

    for panelId, panel in pairs(LCARS.ActivePanels) do
        if panel.Visible then
            if panel.Closing then continue end
            if panel.MenuPos ~= 1 then continue end
            
            for windowId, window in pairs(panel.Windows) do
                local pos = LCARS:Get3D2DMousePos(window, eyePos, eyeVector)

                if pos.x > -window.Width / 2 and pos.x < window.Width / 2 
                and pos.y > -window.Height / 2 and pos.y < window.Height / 2 then
                    local windowType = LCARS.Windows[window.Type]
                    if istable(windowType) then
                        local buttonId = windowType:IsPressed(panel, window, pos)
                        if buttonId then
                            net.Start("LCARS.Screens.Pressed")
                                net.WriteString(panelId)
                                net.WriteInt(windowId, 32)
                                net.WriteInt(buttonId, 32)
                            net.SendToServer()
                        end
                    end
                end
            end
        end
    end
end)

-- Main Render Hook for all LCARS Screens
hook.Add("PostDrawOpaqueRenderables", "LCARS.Screens.Draw", function()
    local eyePos = LocalPlayer():EyePos()
    local eyeVector = EyeVector()

    for _, panel in pairs(LCARS.ActivePanels) do
        if panel.Visible then
            for _, window in pairs(panel.Windows) do
                cam.Start3D2D(window.CenterPos, window.Angles, 1 / window.Scale)
                    local pos = LCARS:Get3D2DMousePos(window, eyePos, eyeVector)

                    if pos.x > -window.Width / 2 and pos.x < window.Width / 2 
                    and pos.y > -window.Height / 2 and pos.y < window.Height / 2 then
                        window.LastPos = pos
                    end
                    
                    local windowType = LCARS.Windows[window.Type]
                    if istable(windowType) then
                        windowType:DrawWindow(panel, window, window.LastPos)
                    end
                cam.End3D2D()
            end
        end
    end
end)
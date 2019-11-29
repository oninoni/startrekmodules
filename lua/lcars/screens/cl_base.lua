

-- List of active Paneln.
-- Filled via Networking.
LCARS.ActivePanels = LCARS.ActivePanels or {}

-- List of Windows.
-- Will be filled by other files.
LCARS.Windows = LCARS.Windows or {}

-- Returns the position of the mouse in the 2d plane of the panel.
--
-- @param Panel panel
-- @param Vector eyePos
-- @param Vector eyeVector
-- @return Vector mousePos
function LCARS:Get3D2DMousePos(panel, eyePos, eyeVector)
    local pos = util.IntersectRayWithPlane(eyePos, eyeVector, panel.ScreenCenterPos, panel.Forward)
    pos = WorldToLocal(pos or Vector(), Angle(), panel.ScreenCenterPos, panel.Angles)

    return Vector(pos.x * panel.Scale, pos.y * -panel.Scale, 0)
end

-- Drawing a normal LCARS panel button. (2D Rendering Context)
--
-- @param Number x
-- @param Number y
-- @param Text text
-- @param Color color
-- @param? Boolean selected
-- @param? String s
-- @param? String l
-- @param? Number alpha
function LCARS:DrawButton(x, y, text, color, selected, s, l, alpha)
    local lcars_white = Color(255, 255, 255, alpha)
    local lcars_black = Color(0, 0, 0, alpha)
    color = ColorAlpha(color, alpha)

    draw.RoundedBox(16, -121 + x, y - 1, 242, 32, selected and lcars_white or lcars_black)
    draw.RoundedBox(15, -120 + x, y, 240, 30, color)
    draw.RoundedBox(0, -100 + x, y, 10, 30, lcars_black)
    draw.RoundedBox(0, 55 + x, y, 15, 30, lcars_black)
    draw.RoundedBox(0, 0 + x, y, 45, 30, lcars_black)

    if #s == 1 then
        draw.DrawText(s, "LCARSBig", 21 + x, y - 4, color, TEXT_ALIGN_LEFT)
    else
        draw.DrawText(s, "LCARSBig", 3 + x, y - 4, color, TEXT_ALIGN_LEFT)
    end

    draw.DrawText(text, "LCARSText", -88 + x, y + 14, lcars_black, TEXT_ALIGN_LEFT)
    draw.DrawText(l, "LCARSSmall", 71 + x, y + 18, lcars_black, TEXT_ALIGN_LEFT)
end

function LCARS:CloseMenu(id)
    LCARS.ActivePanels[id].Closing = true
end

net.Receive("LCARS.Screens.CloseMenu", function()
    local id = net.ReadString()
    
    LCARS:CloseMenu(id)
end)

function LCARS:OpenMenu(id, panelData)
    local panel = {
        Visible = false,

        Scale = panelData.Scale or 20,

        Width = panelData.Width or 300,
        Height = panelData.Height or 300,

        MenuPos = 0,
        Closing = false,
    }

    panel.ScreenCenterPos = panelData.Pos

    panel.Up = panelData.Angles:Up()
    panel.Right = panelData.Angles:Right()
    panel.Forward = panelData.Angles:Forward()

    panel.Angles = panel.Right:AngleEx(panel.Right:Cross(panel.Up))

    panel.Windows = panelData.Windows

    for _, window in pairs(panelData.Windows) do
        window.LastPos = Vector()
    end
    
    LCARS.ActivePanels[id] = panel
end

net.Receive("LCARS.Screens.OpenMenu", function()
    local id = net.ReadString()
    local panelData = net.ReadTable()

    LCARS:OpenMenu(id, panelData)
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
            endpos = panel.ScreenCenterPos,
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

    if key ~= IN_USE then return end

    for panelId, panel in pairs(LCARS.ActivePanels) do
        if panel.Visible then
            if panel.Closing then continue end
            if panel.MenuPos ~= 1 then continue end
            
            local pos = LCARS:Get3D2DMousePos(panel, eyePos, eyeVector)

            if pos.x > -panel.Width / 2 and pos.x < panel.Width / 2 
            and pos.y > -panel.Height / 2 and pos.y < panel.Height / 2 then
                for windowId, window in pairs(panel.Windows) do
                    if pos.x - window.Pos.x > -window.Width / 2 and pos.x - window.Pos.x < window.Width / 2 
                    and pos.y - window.Pos.y > -window.Height / 2 and pos.y - window.Pos.y < window.Height / 2 then
                        local windowType = LCARS.Windows[window.Type]
                        if istable(windowType) then
                            local buttonId = windowType:IsPressed(panel, window, pos)
                            if buttonId then
                                net.Start("LCARS.Screens.Pressed")
                                    net.WriteString(panelId, 32)
                                    net.WriteInt(windowId, 32)
                                    net.WriteInt(buttonId, 32)
                                net.SendToServer()
                            end
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
            cam.Start3D2D(panel.ScreenCenterPos, panel.Angles, 1 / panel.Scale)
                -- Animate Closing/Opening of the Menu

                local pos = LCARS:Get3D2DMousePos(panel, eyePos, eyeVector)

                for _, window in pairs(panel.Windows) do
                    if pos.x - window.Pos.x > -window.Width / 2 and pos.x - window.Pos.x < window.Width / 2 
                    and pos.y - window.Pos.y > -window.Height / 2 and pos.y - window.Pos.y < window.Height / 2 then
                        window.LastPos = pos
                    end
                    
                    local windowType = LCARS.Windows[window.Type]
                    if istable(windowType) then
                        windowType:DrawWindow(panel, window, window.LastPos)
                    end
                end
            cam.End3D2D()
        end
    end
end)
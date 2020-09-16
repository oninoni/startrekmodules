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

-- Recording interact presses and checking interaction with panel
hook.Add("KeyPress", "LCARS.Screens.KeyPress", function(ply, key)
    if not (game.SinglePlayer() or IsFirstTimePredicted()) then return end

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
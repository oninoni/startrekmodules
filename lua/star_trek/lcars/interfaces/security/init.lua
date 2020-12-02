function Star_Trek.LCARS:OpenSecurityMenu()
    local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
    if not success then
        Star_Trek:Message(ent)
        return
    end

    local interfaceData = self.ActiveInterfaces[ent]
    if istable(interfaceData) then
        return
    end

    local modes = {
        "Internal Scanners",
        "Security Measures",
    }
    local buttons = {}
    for i, name in pairs(modes) do
        local color = Star_Trek.LCARS.ColorBlue
        if i % 2 == 0 then
            color = Star_Trek.LCARS.ColorLightBlue
        end

        local buttonData = {
            Name = name,
            Color = color,
        }

        buttons[i] = buttonData
    end

    local modeCount = #modes
    local utilButtonData = {
        Name = "Disable Console",
        Color = Star_Trek.LCARS.ColorRed,
    }
    buttons[modeCount + 2] = utilButtonData

    local height = table.maxn(buttons) * 35 + 80
    local success, menuWindow = Star_Trek.LCARS:CreateWindow("button_list", Vector(-18, -25, 9), Angle(10, 0, -50), 30, 400, height, function(windowData, interfaceData, ent, buttonId)
        if buttonId == modeCount + 2 then
            ent:EmitSound("star_trek.lcars_close")
            Star_Trek.LCARS:CloseInterface(ent)
        else
            print(buttonId)
            -- TODO: Mode Selection
        end
    end , buttons, "Modes")
    if not success then
        Star_Trek:Message(menuWindow)
    end

    local success, sectionWindow = Star_Trek.LCARS:CreateWindow("category_list", Vector(-22, 0, 0), Angle(0, 0, 0), nil, 500, 500, function(windowData, interfaceData, ent, buttonId)
        -- TODO
    end, Star_Trek.LCARS:GetSectionCategories(), "Sections", true)
    if not success then
        Star_Trek:Message(menuWindow)
    end

    local windows = Star_Trek.LCARS:CombineWindows(
        menuWindow,
        sectionWindow
    )

    local success, error = self:OpenInterface(ent, windows)
    if not success then
        Star_Trek:Message(error)
        return
    end
end
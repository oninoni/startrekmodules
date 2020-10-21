function Star_Trek.LCARS:OpenReplicatorMenu()
    local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
    if not success then
        Star_Trek:Message(ent)
        return
    end

    local interfaceData = self.ActiveInterfaces[ent]
    if istable(interfaceData) then
        return
    end

    local categories = table.Copy(Star_Trek.Replicator.Categories)
    local categoryCount = #categories

    table.insert(categories, {
        Name = "Clean",
        Color = Star_Trek.LCARS.ColorOrange,
        Buttons = {},
    })

    table.insert(categories, {
        Name = "Close",
        Color = Star_Trek.LCARS.ColorRed,
        Buttons = {},
    })

    local success2, window = Star_Trek.LCARS:CreateWindow("category_list", Vector(0, 10, 0), Angle(90, 0, 0), nil, 500, 522, function(windowData, interfaceData, ent, categoryId, buttonId)
        if buttonId then
            local selected = windowData.Selected
            local categoryData = windowData.Categories[selected]
            if istable(categoryData) then
                local buttonData = categoryData.Buttons[buttonId]

                if istable(buttonData) then
                    local pos = ent:GetPos()
                    pos = pos + ent:GetUp() * -18
                    pos = pos + ent:GetRight() * 6

                    Star_Trek.Replicator:CreateObject(nil, buttonData.Data, pos, ent:GetAngles(), nil)
                end
            end

            Star_Trek.LCARS:CloseInterface(ent)
        else
            if categoryId == categoryCount + 1 then
                local pos = ent:GetPos()
                pos = pos + ent:GetUp() * -18
                pos = pos + ent:GetRight() * 6

                local entities = ents.FindInSphere(pos, 50)
                for _, cleanEnt in pairs(entities) do
                    Star_Trek.Replicator:RecycleObject(cleanEnt)
                end

                Star_Trek.LCARS:CloseInterface(ent)
            elseif categoryId == categoryCount + 2 then
                Star_Trek.LCARS:CloseInterface(ent)
            end
        end
    end, categories, "Replicator", true)
    if not success2 then
        Star_Trek:Message(menuWindow)
    end

    local windows = Star_Trek.LCARS:CombineWindows(
        window
    )

    local success3, error = self:OpenInterface(ent, windows)
    if not success3 then
        Star_Trek:Message(error)
        return
    end
end
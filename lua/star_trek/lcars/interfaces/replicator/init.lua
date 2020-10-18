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

    local categories = {}
    for i = 1, 4 do
        local category = {
            Name = "Category " .. i,
            Buttons = {},
        }
        for j = 1, 16 do
            local button = {
                Name = "Object " .. i .. " " .. j,
                Data = "models/food/burger.mdl"
            }

            table.insert(category.Buttons, button)
        end

        table.insert(categories, category)
    end
    local categoryCount = #categories

    table.insert(categories, {
        Name = "Close",
        Color = Star_Trek.LCARS.ColorRed,
        Buttons = {},
    })

    local success, window = Star_Trek.LCARS:CreateWindow("category_list", Vector(0, 10, 0), Angle(90, 0, 0), nil, 500, 500, function(windowData, interfaceData, ent, categoryId, buttonId)
        if buttonId then
            print(categoryId, buttonId)

            Star_Trek.LCARS:CloseInterface(ent)
        else
            if categoryId == categoryCount + 1 then
                Star_Trek.LCARS:CloseInterface(ent)
            end
        end
    end, categories, "Replicator", true)
    if not success then
        Star_Trek:Message(menuWindow)
    end

    local windows = Star_Trek.LCARS:CombineWindows(
        window
    )

    local success, error = self:OpenInterface(ent, windows)
    if not success then
        Star_Trek:Message(error)
        return
    end
end
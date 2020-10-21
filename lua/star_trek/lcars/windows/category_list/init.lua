function WINDOW.OnCreate(windowData, categories, title, toggle)
    windowData.Categories = {}
    windowData.Title = title or ""
    windowData.Toggle = toggle

    if not istable(categories) then
        return false
    end

    for i, category in pairs(categories) do
        if not istable(category) or not istable(category.Buttons) then continue end

        local categoryData = {
            Name = category.Name or "MISSING",
            Disabled = category.Disabled or false,
            Data = category.Data,
            Buttons = {}
        }

        if not windowData.Selected then
            windowData.Selected = i
        end

        if IsColor(category.Color) then
            categoryData.Color = category.Color
        else
            if i % 2 == 0 then
                categoryData.Color = Star_Trek.LCARS.ColorLightBlue
            else
                categoryData.Color = Star_Trek.LCARS.ColorBlue
            end
        end

        categoryData.RandomS = Star_Trek.LCARS:GetSmallNumber(category.RandomS)
        categoryData.RandomL = Star_Trek.LCARS:GetLargeNumber(category.RandomL)

        for j, button in pairs(category.Buttons) do
            local buttonData = {
                Name = button.Name or "MISSING",
                Disabled = button.Disabled or false,
                Data = button.Data,
            }

            if IsColor(button.Color) then
                buttonData.Color = button.Color
            else
                if windowData.Toggle then
                    if j % 2 == 0 then
                        buttonData.Color = Star_Trek.LCARS.ColorLightBlue
                    else
                        buttonData.Color = Star_Trek.LCARS.ColorBlue
                    end
                else
                    buttonData.Color = table.Random(Star_Trek.LCARS.Colors)
                end
            end

            buttonData.RandomS = Star_Trek.LCARS:GetSmallNumber(button.RandomS)
            buttonData.RandomL = Star_Trek.LCARS:GetLargeNumber(button.RandomL)

            table.insert(categoryData.Buttons, buttonData)
        end

        categoryData.Id = table.insert(windowData.Categories, categoryData)
    end

    return windowData
end

function WINDOW.GetSelected(windowData)
    local data = {
        Buttons = {}
    }

    local categoryData = windowData.Categories[windowData.Selected]
    if istable(categoryData) then
        data.Selected = categoryData.Name
        for _, buttonData in pairs(categoryData.Buttons) do
            data.Buttons[buttonData.Name] = buttonData.Selected
        end
    end

    return data
end

function WINDOW.SetSelected(windowData, data)
    for i, categoryData in pairs(windowData.Categories) do
        if categoryData.Name == data.Selected then
            windowData.Selected = i

            for name, selected in pairs(data.Buttons) do
                for _, buttonData in pairs(categoryData.Buttons) do
                    if buttonData.Name == name then
    	                buttonData.Selected = selected
                        break
                    end
                end
            end

            break
        end
    end
end

function WINDOW.OnPress(windowData, interfaceData, ent, buttonId, callback)
    local categoryId = windowData.Selected
    local categoryCount = table.Count(windowData.Categories)
    local categoryData = windowData.Categories[categoryId]

    local shouldUpdate = false

    if buttonId <= categoryCount then
        -- Category Selection
        if buttonId ~= categoryId then
            local newData = windowData.Categories[buttonId]
            if istable(newData) and not newData.Disabled then
                ent:EmitSound("buttons/blip1.wav")
                -- TODO: Replace Sound

                windowData.Selected = buttonId

                for _, buttonData in pairs(categoryData.Buttons) do
                    buttonData.Selected = nil
                end

                shouldUpdate = true

                if isfunction(callback) then
                    callback(windowData, interfaceData, ent, buttonId, nil)
                end
            else
                ent:EmitSound("buttons/combine_button_locked.wav")
                -- TODO: Replace Sound
            end

        end
    else
        ent:EmitSound("buttons/blip1.wav")
        -- TODO: Replace Sound

        -- Buttons
        buttonId = buttonId - categoryCount

        if windowData.Toggle then
            local buttonData = categoryData.Buttons[buttonId]
            if istable(buttonData) then
                buttonData.Selected = not (buttonData.Selected or false)
                shouldUpdate = true
            end
        end

        if isfunction(callback) then
            local updated = callback(windowData, interfaceData, ent, categoryId, buttonId)
            if updated then
                shouldUpdate = true
            end
        end
    end

    return shouldUpdate
end
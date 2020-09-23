function WINDOW.OnCreate(windowData, buttons, title, toggle)
    windowData.Buttons = {}
    windowData.Title = title or ""
    windowData.Toggle = toggle

    if not istable(buttons) then
        return false
    end

    for i, button in pairs(buttons) do
        local buttonData = {
            Name = button.Name or "MISSING",
            Disabled = button.Disabled or false,
            Data = button.Data,
        }

        if IsColor(button.Color) then
            buttonData.Color = button.Color
        else            
            if windowData.Toggle then
                if i%2 == 0 then
                    buttonData.Color = Star_Trek.LCARS.ColorLightBlue
                else
                    buttonData.Color = Star_Trek.LCARS.ColorBlue
                end
            else
                buttonData.Color = table.Random(Star_Trek.LCARS.Colors)
            end
        end

        local s
        if isnumber(button.RandomS) then
            if not (button.RandomS >= 0 and button.RandomS < 100) then
                return
            end

            s = button.RandomS
        else
            s = math.random(0, 99)
        end
        if s < 10 then
            buttonData.RandomS = "0" .. tostring(s)
        else
            buttonData.RandomS = tostring(s)
        end

        local l
        if isnumber(button.RandomL) then
            if not (button.RandomL >= 0 and button.RandomL < 1000000) then
                return
            end

            l = button.RandomL
        else
            l = math.random(0, 999999)
        end

        if l < 10 then
            buttonData.RandomL = "00000" .. tostring(l)
        elseif l < 100 then
            buttonData.RandomL = "0000" .. tostring(l)
        elseif l < 1000 then
            buttonData.RandomL = "000" .. tostring(l)
        elseif l < 10000 then
            buttonData.RandomL = "00" .. tostring(l)
        elseif l < 100000 then
            buttonData.RandomL = "0" .. tostring(l)
        else
            buttonData.RandomL = tostring(l)
        end

        buttonData.RandomL = string.sub(buttonData.RandomL, 1, 2) .. "-" .. string.sub(buttonData.RandomL, 3)

        windowData.Buttons[i] = buttonData
    end

    return windowData
end

function WINDOW.GetData(windowData)
    local data = {}
    for _, button in pairs(windowData.Buttons) do
        data[button.Name] = button.Selected
    end

    return data
end

function WINDOW.SetData(windowData, data)
    for name, selected in pairs(data) do
        for _, button in pairs(windowData.Buttons) do
            if button.Name == name then
    	        button.Selected = selected
                break
            end
        end
    end
end

function WINDOW.OnPress(windowData, interfaceData, ent, buttonId, callback)
    ent:EmitSound("buttons/blip1.wav")
    -- TODO: Replace Sound

    local shouldUpdate = false

    if windowData.Toggle then
        local button = windowData.Buttons[buttonId]
        if istable(button) then
            button.Selected = not (button.Selected or false)
            shouldUpdate = true
        end
    end

    if isfunction(callback) then
        local updated = callback(windowData, interfaceData, ent, buttonId)
        if updated then 
            shouldUpdate = true
        end
    end

    return shouldUpdate
end
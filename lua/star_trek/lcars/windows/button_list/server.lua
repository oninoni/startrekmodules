function WINDOW.OnCreate(windowData, buttons)
    windowData.Buttons = {}

    if not istable(buttons) then
        return false
    end

    for i, button in pairs(buttons) do
        local buttonData = {
            Name = button.Name or "MISSING",
            Disabled = button.Disabled or false,
        }

        if IsColor(button.Color) then
            buttonData.Color = button.Color
        else            
            buttonData.Color = table.Random(Star_Trek.LCARS.Colors)
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

        table.insert(windowData.Buttons, buttonData)
    end

    return windowData
end

function WINDOW.OnPress(self)

end

function WINDOW.OnTick(self)

end
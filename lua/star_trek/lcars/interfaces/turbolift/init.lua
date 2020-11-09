local function generateButtons(ent, keyValues)
    local buttons = {}

    local name = ""
    if ent.IsTurbolift then
        name = keyValues["lcars_name"]
    elseif ent.IsPod then
        local podData = ent.Data

        local controlButton = {}
        if podData.Stopped or podData.TravelTarget == nil then
            controlButton.Name = "Resume Lift"
        else
            controlButton.Name = "Stop Lift"
        end
        controlButton.Color = Star_Trek.LCARS.ColorRed

        buttons[1] = controlButton
    end

    for i, turboliftData in SortedPairs(Star_Trek.Turbolift.Lifts) do
        local button = {
            Name = turboliftData.Name,
            Disabled = turboliftData.Name == name,
        }

        buttons[#buttons + 1] = button
    end

    return buttons
end

-- Opening a turbolift control menu.
function Star_Trek.LCARS:OpenTurboliftMenu()
    local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
    if not success then
        -- Error Message
        Star_Trek:Message(ent)
        return
    end

    local interfaceData = self.ActiveInterfaces[ent]
    if istable(interfaceData) then
        return
    end

    local keyValues = ent.LCARSKeyData
    if not istable(keyValues) then
        Star_Trek:Message("Invalid Key Values on OpenTLMenu")
        return
    end

    local buttons = generateButtons(ent, keyValues)

    local success, window = self:CreateWindow("button_list", Vector(), Angle(), 30, 600, 300, function(windowData, interfaceData, ent, buttonId)
        if ent.IsTurbolift then
            Star_Trek.Turbolift:StartLift(ent, buttonId)

            ent:EmitSound("star_trek.lcars_close")
            Star_Trek.LCARS:CloseInterface(ent)
        elseif ent.IsPod then
            if buttonId == 1 then
                if Star_Trek.Turbolift:TogglePos(ent) then
                    windowData.Buttons[1].Name = "Resume Lift"
                else
                    windowData.Buttons[1].Name = "Stop Lift"
                end

                return true
            else
                Star_Trek.Turbolift:ReRoutePod(ent, buttonId - 1)

                ent:EmitSound("star_trek.lcars_close")
                Star_Trek.LCARS:CloseInterface(ent)
            end
        end
    end, buttons, "Turbolift")
    if not success then
        Star_Trek:Message(window)
        return
    end

    local windows = Star_Trek.LCARS:CombineWindows(window)

    local success, error = self:OpenInterface(ent, windows)
    if not success then
        Star_Trek:Message(error)
        return
    end
end
local function generateButtons(ent, keyValues)
    local buttons = {}

    local name = ""
    if ent.IsTurbolift then
        name = keyValues["lcars_name"]
    elseif ent.IsPod then
        local controlButton = {
            Name = "",
        }

        local podData = ent.Data
        local controlButton = {}
        if podData.Stopped or podData.TravelTarget == nil then
            controlButton.Name = "Resume Lift"
        else
            controlButton.Name = "Stop Lift"
        end

        buttons[1] = controlButton
    end

    for i, turboliftData in SortedPairs(Star_Trek.Turbolift.Lifts) do
        local button = {
            Name = turboliftData.Name,
            Disabled = turboliftData.Name == name,
        }

        buttons[#buttons+1] = button
    end

    return buttons
end

-- Opening a turbolift control menu.
function Star_Trek.LCARS:OpenTurboliftMenu()
    local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
    if not success then 
        -- Error Message
        print("[Star Trek] " .. ent)
        return
    end

    local keyValues = ent.LCARSKeyData
    if not istable(keyValues) then
        print("[Star Trek] Invalid Key Values on OpenTLMenu")
        return
    end

    local buttons = generateButtons(ent, keyValues)

    local success, data = self:CreateWindow("button_list", Vector(), Angle(), 30, 600, 300, function(windowData, interfaceData, ent, buttonId)
        if ent.IsTurbolift then
            Star_Trek.Turbolift:StartLift(ent, buttonId)
            Star_Trek.LCARS:CloseInterface(ent)
        elseif ent.IsPod then
            if buttonId == 1 then
                if Star_Trek.Turbolift:TogglePos(ent) then
                    windowData.Buttons[1].Name = "Resume Lift"
                else
                    windowData.Buttons[1].Name = "Stop Lift"
                end

                Star_Trek.LCARS:UpdateWindow(ent, 1)
            else
                Star_Trek.Turbolift:ReRoutePod(ent, buttonId - 1)
                Star_Trek.LCARS:CloseInterface(ent)
            end
        end
    end, buttons)
    if not success then
        print("[Star Trek] " .. data)
        return
    end

    local windows = {
        [1] = data
    }

    local success, error = self:OpenInterface(ent, windows)
    if not success then
        print("[Star Trek] " .. error)
        return
    end
end

-- TODO: Get rid of by changing map
LCARS = LCARS or {}
function LCARS:OpenTurboliftMenu()
    Star_Trek.LCARS:OpenTurboliftMenu()
end
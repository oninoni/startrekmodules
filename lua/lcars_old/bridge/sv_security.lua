LCARS.SecurityModes = {
    "Internal Scanners",
    "Doors",
    "Forcefields",
    "Turbolifts",
}

LCARS.Security = {}

local setupSecurity = function()
    local scanners = {}
    LCARS.Security.Scanners = scanners
    for i=1,15,1 do
        scanners[i] = {
            Name = "Deck " .. i,
            Positions = {},
        }
    end

    local beamLocations = ents.FindByName("beamLocation")

    for _, ent in pairs(beamLocations) do
        local name = ent.LCARSKeyData["lcars_name"]
        local nameData = string.Split(name, "-")

        local deckNumber = tonumber(string.sub(nameData[1], 5))
        table.insert(scanners[deckNumber].Positions, ent:GetPos())
    end

    for _, scanner in pairs(scanners) do
        PrintTable(scanner.Positions)
    end
end
hook.Add("InitPostEntity", "LCARS.Security.Setup", setupSecurity)
hook.Add("PostCleanupMap", "LCARS.Security.Setup", setupSecurity)

function LCARS:OpenSecurityStationMenu()
    local panel = self:OpenMenuInternal(TRIGGER_PLAYER, CALLER, function(ply, panel_brush, panel, screenPos, screenAngle)
        local fOffset = -screenAngle:Forward()
        local rOffset = screenAngle:Right()
        local uOffset = screenAngle:Up()

        debugoverlay.Cross(screenPos, 10, 2)
        
        debugoverlay.Cross(screenPos + fOffset*5 - rOffset*20 - uOffset*28, 10, 2)
        debugoverlay.Cross(screenPos + fOffset*5 + rOffset*20 - uOffset*28, 10, 2)

        local panelData = {
            Type = "Security",
            Pos = screenPos,
            Windows = {
                [1] = {
                    Pos = screenPos + fOffset*5 - rOffset*20 - uOffset*28,
                    Angles = screenAngle - Angle(-40, 0, 0),
                    Type = "button_list",
                    Width = 350,
                    Height = 300,
                    Buttons = {}
                },
                [2] = {
                    Pos = screenPos + fOffset*5 + rOffset*20 - uOffset*28,
                    Angles = screenAngle - Angle(-40, 0, 0),
                    Type = "button_list",
                    Width = 350,
                    Height = 300,
                    Buttons = {}
                },
            },
        }

        for i, buttonName in pairs(LCARS.SecurityModes) do
            local color = LCARS.ColorBlue
            if i%2 == 0 then
                color = LCARS.ColorLightBlue
            end
            
            local button = LCARS:CreateButton(buttonName, color, buttonName == "Forcefields" or buttonName == "Doors")
            table.insert(panelData.Windows[1].Buttons, button)
        end
        
        panelData.Windows[1].Buttons[6] = LCARS:CreateButton("Disable Console", LCARS.ColorRed)
        panelData.Windows[1].Buttons[6].Selected = false

        self.Security:ApplySelection(panelData, 1)
        
        self:SendPanel(panel, panelData)
    end)
end

function LCARS.Security:ApplySelection(panelData, selection)
    panelData.Windows[1].Selection = selection
    panelData.Windows[1].Buttons[selection].Color = LCARS.ColorYellow
end

hook.Add("LCARS.PressedCustom", "LCARS.Security.Pressed", function(ply, panelData, panel, panelBrush, windowId, buttonId)
    if panelData.Type ~= "Security" then return end

    local window = panelData.Windows[windowId]
    if not istable(window) then return end

    local button = window.Buttons[buttonId]
    
    if windowId == 1 then
        local buttonName = window.Buttons[buttonId].Name

        if buttonName == "Disable Console" then
            LCARS:DisablePanel(panel)
            return
        end

        -- Select Mode
        LCARS.Security:ApplySelection(panelData, buttonId)

        -- Apply Mode
        if buttonName == "Internal Scanners" then
            for _, scanner in pairs(LCARS.Security.Scanners) do

            end
        elseif buttonName == "Doors" then
            
        elseif buttonName == "Forcefields" then
            
        elseif buttonName == "Turbolifts" then
            
        end
    end
end)
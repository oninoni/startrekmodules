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

        for i=1,4,1 do
            local button = LCARS:CreateButton("Test", Color(255, 255, 255))
            table.insert(panelData.Windows[1].Buttons, button)
        end

        for i=1,4,1 do
            local button = LCARS:CreateButton("Test", Color(255, 255, 255))
            table.insert(panelData.Windows[2].Buttons, button)
        end

        self:SendPanel(panel, panelData)
    end)
end
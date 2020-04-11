function LCARS:OpenBridgeTransporter()
    local panel = self:OpenMenuInternal(TRIGGER_PLAYER, CALLER, function(ply, panel_brush, panel, screenPos, screenAngle)
        panel.TargetNames = {
            "Transporter Pads",
            "Lifeforms",
            "Locations",
        }

        local fOffset = -screenAngle:Forward()
        local rOffset = screenAngle:Right()
        local uOffset = screenAngle:Up()

        local panelData = {
            Type = "Transporter",
            Pos = screenPos + Vector(0, 20, 0),
            Windows = {
                [1] = {
                    Pos = screenPos + fOffset*5 - rOffset*20 - uOffset*28,
                    Angles = screenAngle - Angle(-35, 0, 0),
                    Type = "button_list",
                    Width = 350,
                    Height = 300,
                    Buttons = {}
                },
                [2] = {
                    Pos = screenPos + fOffset*5 + rOffset*20 - uOffset*28,
                    Angles = screenAngle - Angle(-35, 0, 0),
                    Type = "button_list",
                    Width = 350,
                    Height = 300,
                    Buttons = {}
                },
                [3] = {
                    Pos = screenPos + fOffset*0 - rOffset*20 + uOffset*0,
                    Angles = screenAngle - Angle(0, 0, 0),
                    Type = "button_list",
                    Width = 500,
                    Height = 500,
                    Buttons = {}
                },
                [4] = {
                    Pos = screenPos + fOffset*0 + rOffset*20 + uOffset*0,
                    Angles = screenAngle - Angle(0, 0, 0),
                    Type = "button_list",
                    Width = 500,
                    Height = 500,
                    Buttons = {}
                },
                [5] = {
                    Pos = screenPos + fOffset*6 + rOffset*0  - uOffset*28,
                    Angles = screenAngle - Angle(-35, 0, 0),
                    Type = "transport_slider",
                    Width = 150,
                    Height = 150,
                    Buttons = {}
                },
            },
        }

        for i=1,2,1 do
            for j=1,#(panel.TargetNames),1 do
                local color = LCARS.ColorBlue
                if (i + j)%2 == 0 then
                    color = LCARS.ColorLightBlue
                end

                local targetName = panel.TargetNames[j]
                if istable(targetName) then
                    targetName = targetName[i]
                end
                
                local button = LCARS:CreateButton(targetName, color)
                button.DeselectedColor = color

                table.insert(panelData.Windows[i].Buttons, button)
            end
        end

        panelData.Windows[1].Selected = 2
        panelData.Windows[1].Buttons[2].Color = LCARS.ColorYellow
        panelData.Windows[2].Selected = 1
        panelData.Windows[2].Buttons[1].Color = LCARS.ColorYellow

        panelData.Windows[1].Buttons[5] = LCARS:CreateButton("Swap Sides", LCARS.ColorOrange)
        panelData.Windows[1].Buttons[5].Selected = false
        panelData.Windows[2].Buttons[5] = LCARS:CreateButton("Disable Console", LCARS.ColorRed)
        panelData.Windows[2].Buttons[5].Selected = false

        for i=1,2,1 do
            LCARS:ReplaceButtons(panel, panelData.Windows[2 + i], panelData.Windows[i].Selected, i == 2)
        end

        self:SendPanel(panel, panelData)
    end)
end
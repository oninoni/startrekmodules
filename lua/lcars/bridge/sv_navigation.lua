

function LCARS:OpenNavComputerMenu()
    local panel = self:OpenMenuInternal(TRIGGER_PLAYER, CALLER, function(ply, panel_brush, panel, screenPos, screenAngle)
        local panelData = {
            Type = "Navigation",
            Pos = screenPos,
            Windows = {
                [1] = {
                    Pos = screenPos,
                    Angles = screenAngle,
                    Type = "button_list",
                    Width = 400,
                    Height = 400,
                    Buttons = {}
                },
            },
        }

        for i=1,4,1 do
            local button = LCARS:CreateButton("Test", Color(255, 255, 255))
            table.insert(panelData.Windows[1].Buttons, button)
        end

        self:SendPanel(panel, panelData)
    end)
end
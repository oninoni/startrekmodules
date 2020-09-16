function LCARS:UpdateWindow(panel, windowId, window)
    local panelData = self.ActivePanels[panel]

    panelData.Windows[windowId] = window

    net.Start("LCARS.Screens.UpdateWindow")
        net.WriteString("ENT_" .. panel:EntIndex())
        net.WriteInt(windowId, 32)
        net.WriteTable(window)
    net.Broadcast()
end

-- Detect Updates in _name, _disabled.
hook.Add("Star_Trek.ChangedKeyValue", "LCARS.Screens.ValueChanged", function(ent, key, value)
    if string.StartWith(key, "lcars_name_") or string.StartWith(key, "lcars_disabled_") then
        local keyValues = ent.LCARSKeyData
        if istable(keyValues) and keyValues["lcars_keep_open"] then
            ent.LCARSMenuHasChanged = true
        end
    end
end)

-- Receive the pressed event from the client when a user presses his panel.
net.Receive("LCARS.Screens.Pressed", function(len, ply)
    local panelId = net.ReadString()
    local windowId = net.ReadInt(32)
    local buttonId = net.ReadInt(32)

    local entId = tonumber(string.sub(panelId, 5))
    local panel = ents.GetByIndex(entId)
    if not IsValid(panel) then return end

    -- TODO: Replace Sound
    panel:EmitSound("buttons/blip1.wav")

    local panel_brush = panel:GetParent()
    if not IsValid(panel_brush) then 
        panel_brush = panel
    end

    local panelData = LCARS.ActivePanels[panel]
    if not istable(panelData) then return end

    if panelData.Type == "Universal" then
        if buttonId > 4 then
            local name = panel_brush:GetName()
            local caseEntities = ents.FindByName(name .. "_case")
            for _, caseEnt in pairs(caseEntities) do
                if IsValid(caseEnt) then
                    caseEnt:Fire("InValue", buttonId - 4)
                end
            end
        else
            panel_brush:Fire("FireUser" .. buttonId)
        end
        
        local keyValues = panel_brush.LCARSKeyData
        if istable(keyValues) and not keyValues["lcars_keep_open"] then
            timer.Simple(0.5, function()
                LCARS:DisablePanel(panel)
            end)
        end
    else
        hook.Run("LCARS.PressedCustom", ply, panelData, panel, panelBrush, windowId, buttonId)
    end
end)
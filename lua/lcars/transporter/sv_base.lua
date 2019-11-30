
-- List of active Transports.
LCARS.ActiveTransports = LCARS.ActiveTransports or {}

util.AddNetworkString("LCARS.Tranporter.BeamObject")

function LCARS:BroadcastBeamEffect(ent, rematerialize)
    if not IsValid(ent) then return end
    
    local oldCollisionGroup = ent:GetCollisionGroup()
    ent:SetCollisionGroup(COLLISION_GROUP_NONE)

    local players = {}
    for _, ply in pairs(player.GetHumans()) do
        --local trace = util.TraceLine({
        --    start = ply:GetShootPos(),
        --    endpos = ent:GetPos(),
        --    filter = ply,
        --    mask = MASK_NPCWORLDSTATIC,
        --})

        --if not trace.Hit then
        --    table.insert(players, ply)
        --end

        if ply:VisibleVec(ent:GetPos()) then
            table.insert(players, ply)
        end
    end

    ent:SetCollisionGroup(oldCollisionGroup)

    if rematerialize then
        ent:EmitSound("voyager.beam_down")
    else
        ent:EmitSound("voyager.beam_up")
    end

    timer.Simple(0.5, function()
        net.Start("LCARS.Tranporter.BeamObject")
            net.WriteEntity(ent)
            net.WriteBool(rematerialize)
        net.Send(players)
    end)
end

function LCARS:BeamObject(ent, targetPos)
    local transportData = {
        Object = ent,
        TargetPos = targetPos,
        StateTime = CurTime(),
        State = 0,
    }

    for _, transportData in pairs(self.ActiveTransports) do
        if transportData.Object == ent then return end
    end
    
    transportData.OldRenderMode = ent:GetRenderMode()
    ent:SetRenderMode(RENDERMODE_TRANSTEXTURE)

    transportData.OldCollisionGroup = ent:GetCollisionGroup()
    ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    local phys = ent:GetPhysicsObject()
    if phys then
        transportData.OldMotionEnabled = phys:IsMotionEnabled()
        phys:EnableMotion(false)
    end
    
    ent:DrawShadow(false)

    self:BroadcastBeamEffect(ent, false)
    
    table.insert(self.ActiveTransports, transportData)
end

function LCARS:ReaplaceModeButtons(windowId, listWindow, objects)
    listWindow.Buttons = {}

    local j = 1
    for _, object in pairs(objects) do
        local color = LCARS.ColorBlue
        if (windowId + j)%2 == 0 then
            color = LCARS.ColorLightBlue
        end

        local button = LCARS:CreateButton(object.Name, color)
        button.Data = object.Data
        
        button.Selected = false
        button.DeselectedColor = color

        table.insert(listWindow.Buttons, button)

        j = j + 1
    end
end

function LCARS:ReplaceButtons(windowId, listWindow, mode)
    local objects = {}

    if mode == 1 then
        -- TODO Own Pad first

        for _, ent in pairs(ents.GetAll()) do
            local name = ent:GetName()
            if string.StartWith(name, "TRPad") then
                local values = string.Split(string.sub(name, 6), "_")
                local k = values[2]
                local n = values[1]
                
                local object = {
                    Name = ent:GetName(),
                    Data = ent,
                }
                table.insert(objects, object)
            end
        end
    elseif mode == 2 then
        -- TODO: Maybe add NPC's?
        for i=1,8,1 do
        for _, ply in pairs(player.GetHumans()) do
            local object = {
                Name = ply:GetName(),
                Data = ply:SteamID64(),
            }

            table.insert(objects, object)
        end
        end
    elseif mode == 3 then
        -- TODO: Add Markers
    end

    return self:ReaplaceModeButtons(windowId, listWindow, objects)
end

local targetNames = {
    "Transporter Pad",
    "Crew",
    "Marker",
}
function LCARS:OpenTransporterMenu()
    local panel = self:OpenMenuInternal(TRIGGER_PLAYER, CALLER, function(ply, panel_brush, panel, screenPos, screenAngle)
        local panelData = {
            Type = "Transporter",
            Pos = screenPos + Vector(0, 0, 10),
            Width = 2000,
            Height = 300,
            Windows = {
                [1] = {
                    Pos = screenPos + Vector(14, 0, 10),
                    Angles = screenAngle - Angle(20, -20, 0),
                    Type = "button_list",
                    Width = 350,
                    Height = 300,
                    Buttons = {}
                },
                [2] = {
                    Pos = screenPos + Vector(-14, 0, 10),
                    Angles = screenAngle - Angle(20, 20, 0),
                    Type = "button_list",
                    Width = 350,
                    Height = 300,
                    Buttons = {}
                },
                [3] = {
                    Pos = screenPos + Vector(32, 12, 10),
                    Angles = screenAngle - Angle(20, -45, 0),
                    Type = "button_list",
                    Width = 600,
                    Height = 300,
                    Buttons = {}
                },
                [4] = {
                    Pos = screenPos + Vector(-32, 12, 10),
                    Angles = screenAngle - Angle(20, 45, 0),
                    Type = "button_list",
                    Width = 600,
                    Height = 300,
                    Buttons = {}
                },
            },
        }

        for i=1,2,1 do
            for j=1,3,1 do
                local color = LCARS.ColorBlue
                if (i + j)%2 == 0 then
                    color = LCARS.ColorLightBlue
                end

                local button = LCARS:CreateButton(targetNames[j], color)
                button.DeselectedColor = color

                table.insert(panelData.Windows[i].Buttons, button)
            end
        end

        panelData.Windows[1].Selected = 2
        panelData.Windows[1].Buttons[2].Color = LCARS.ColorYellow
        panelData.Windows[2].Selected = 1
        panelData.Windows[2].Buttons[1].Color = LCARS.ColorYellow

        panelData.Windows[1].Buttons[5] = LCARS:CreateButton("Narrow Beam", LCARS.ColorOrange)
        panelData.Windows[1].Buttons[5].Selected = false
        panelData.Windows[2].Buttons[5] = LCARS:CreateButton("Direct Transport", LCARS.ColorOrange)
        panelData.Windows[2].Buttons[5].Selected = false

        for i=1,2,1 do
            LCARS:ReplaceButtons(i, panelData.Windows[2 + i], panelData.Windows[i].Selected)
        end


        self:SendPanel(panel, panelData)
    end)
    
    if IsValid(panel) then
        

        local panel_brush = CALLER
        panel_brush:Fire("FireUser1")

        timer.Simple(4, function()
            panel_brush:Fire("FireUser2")
        end)
    end
end

-- Call FireUser on all Presses
hook.Add("LCARS.PressedCustom", "LCARS.Transporter.Pressed", function(ply, panelData, panel, panelBrush, windowId, buttonId)
    if not panelData.Type == "Transporter" then return end
    
    local window = panelData.Windows[windowId]
    if not istable(window) then return end

    local button = window.Buttons[buttonId]
    if not istable(button) then return end

    if windowId == 1 or windowId == 2 then
        if buttonId >= 1 and buttonId <= 3 then
            local listWindow = panelData.Windows[2 + windowId]

            for i=1,3,1 do
                window.Buttons[i].Color = window.Buttons[i].DeselectedColor
            end

            window.Selected = buttonId
            window.Buttons[window.Selected].Color = LCARS.ColorYellow

            LCARS:ReplaceButtons(windowId, listWindow, window.Selected)

            LCARS:UpdateWindow(panel, windowId, window)
            LCARS:UpdateWindow(panel, windowId + 2, listWindow)
        elseif buttonId == 5 then
            button.Selected = not button.Selected
            
            if button.Selected then
                button.Color = LCARS.ColorRed
                if windowId == 1 then
                    button.Name = "Wide Beam"
                else
                    button.Name = "Buffer Transport"
                end
            else
                button.Color = LCARS.ColorOrange
                if windowId == 1 then
                    button.Name = "Narrow Beam"
                else
                    button.Name = "Direct Transport"
                end
            end

            LCARS:UpdateWindow(panel, windowId, window)
        end
        

        
    elseif windowId == 3 or windowId == 4 then
        button.Selected = not button.Selected

        if button.Selected then
            button.Color = LCARS.ColorYellow
        else
            button.Color = button.DeselectedColor
        end

        LCARS:UpdateWindow(panel, windowId, window)
    end
end)

hook.Add("Think", "LCARS.Tranporter.Cycle", function()
    local toBeRemoved = {}
    for _, transportData in pairs(LCARS.ActiveTransports) do
        local curTime = CurTime()

        local stateTime = transportData.StateTime
        local state = transportData.State
        local ent = transportData.Object
        if IsValid(ent) then
            if state == 0 and (stateTime + 3) < curTime then
                ent:SetRenderMode(RENDERMODE_NONE)
                
                transportData.StateTime = curTime
                transportData.State = 1
            elseif state == 1 and (stateTime + 4) < curTime then
                ent:SetRenderMode(RENDERMODE_TRANSTEXTURE)
                
                LCARS:BroadcastBeamEffect(ent, true)
                
                transportData.StateTime = curTime
                transportData.State = 2
            elseif state == 2 and (stateTime + 3) < curTime then
                ent:SetRenderMode(transportData.OldRenderMode)
                ent:SetCollisionGroup(transportData.OldCollisionGroup)
                    
                local phys = ent:GetPhysicsObject()
                if phys then
                    phys:EnableMotion(transportData.OldMotionEnabled)
                    phys:Wake()
                end
            
                ent:DrawShadow(true)

                ent:Activate()
            
                table.insert(toBeRemoved, transportData)
            end
        else
            table.insert(toBeRemoved, transportData)
        end

        
    end

    for _, transportData in pairs(toBeRemoved) do
        table.RemoveByValue(LCARS.ActiveTransports, transportData)
    end
end)
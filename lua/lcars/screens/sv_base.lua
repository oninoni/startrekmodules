

-- List of active Paneln.
-- Filled via Networking.
LCARS.ActivePanels = LCARS.ActivePanels or {}

util.AddNetworkString("LCARS.Screens.OpenMenu")
util.AddNetworkString("LCARS.Screens.CloseMenu")
util.AddNetworkString("LCARS.Screens.Pressed")

-- Returns the corrent menu Position and orientation for a given panel.
--
-- @param Entity panel
-- @return Vector screenPos
-- @return Angle screenAngle
function LCARS:GetMenuPos(panel)
    local pos = panel:GetPos()
    local screenAngle = panel:GetAngles()

    local attachmentID = panel:LookupAttachment("button")
    if isnumber(attachmentID) and attachmentID > 0 then
        local attachmentPoint = panel:GetAttachment(attachmentID)
        pos = attachmentPoint.Pos
        screenAngle = attachmentPoint.Ang
        
        screenAngle:RotateAroundAxis(screenAngle:Up(), 180)
    else
        screenAngle:RotateAroundAxis(screenAngle:Forward(), 180)
        screenAngle:RotateAroundAxis(screenAngle:Right(), 90)
    end

    local offset = 2
    local modelSetting = self.ModelSettings[panel:GetModel()]
    if modelSetting then
        offset = modelSetting.Offset
    end

    local screenPos = pos + screenAngle:Forward() * offset 
    
    return screenPos, screenAngle
end

-- Returns the menu prop from the brush and player.
--
-- @param Player ply
-- @param Entity panel_brush
-- @return Entity panel
function LCARS:GetMenuProp(ply, panel_brush)
    if not (IsValid(ply) and ply:IsPlayer()) then return end
    if not IsValid(panel_brush) then return end

    local panel = ply:GetEyeTrace().Entity
    if not IsValid(panel) then return end
    local children = panel_brush:GetChildren()
    if not table.HasValue(children, panel) then return end

    return panel
end

-- Validates panel and brush for using a menu on it.
--
-- @param Player ply
-- @param Entity panel_brush
-- @param Function callback
function LCARS:OpenMenuInternal(ply, panel_brush, callback)
    local panel = LCARS:GetMenuProp(ply, panel_brush)
    if not IsValid(panel) then return end

    if istable(self.ActivePanels[panel]) then return end

    if panel:GetPos():Distance(ply:GetPos()) > 100 then return end

    local screenPos, screenAngle = self:GetMenuPos(panel)

    if isfunction(callback) then
        callback(ply, panel_brush, panel, screenPos, screenAngle)
    end
end

function LCARS:ActivatePanel(panel, panelData)
    self.ActivePanels[panel] = panelData

    net.Start("LCARS.Screens.OpenMenu")
        net.WriteString("ENT_" .. panel:EntIndex())
        net.WriteTable(panelData)
    net.Broadcast()
end

function LCARS:DisablePanel(panel)
    self.ActivePanels[panel] = nil

    net.Start("LCARS.Screens.CloseMenu")
        net.WriteString("ENT_" .. panel:EntIndex())
    net.Broadcast()
end

-- TODO: Sync Active Panels to joining players

-- Sends the panel and it's data to the client.
--
-- @param Entity panel
-- @param Table panelData
function LCARS:SendPanel(panel, panelData)
    if not IsValid(panel) then return end
    if not (istable(panelData) and table.Count(panelData) > 0) then return end

    panelData.Visible = panelData.Visible or false

    panelData.Scale = panelData.Scale or 20
    
    panelData.Width = panelData.Width or 300
    panelData.Height = panelData.Height or 300

    panelData.Pos = panelData.Pos or Vector()
    panelData.Angles = panelData.Angles or Angle()

    panelData.Windows = panelData.Windows or {}
    for _, window in pairs(panelData.Windows) do
        window.Width = window.Width or 300
        window.Height = window.Height or 300
    end
    
    self:ActivatePanel(panel, panelData)
end

-- Open a General LCARS Menu using the keyvalues of an panel's func_button brush.
function LCARS:OpenMenu()
    self:OpenMenuInternal(TRIGGER_PLAYER, CALLER, function(ply, panel_brush, panel, screenPos, screenAngle)
        local panelData = {
            Pos = screenPos,
            Angles = screenAngle,
            Windows = {
                [1] = {
                    Pos = Vector(),
                    Type = "button_list",
                    Buttons = {}
                }
            },
        }

        local keyValues = panel_brush.LCARSKeyData

        for i=1,4 do
            local name = keyValues["lcars_name_" .. i]
            if isstring(name) then
                local button = {Name = name}

                local disabled = keyValues["lcars_disabled_" .. i]
                if disabled then
                    button.Disabled = (disabled == "true")
                end

                button.Color = LCARS.Colors[math.random(1, #(LCARS.Colors))]

                button.RandomS = "" .. math.random(1, 99)

                local r = math.random(1, 99)
                local d = math.random(1, 9999)
                
                local v
                if r > 9 then
                    v = "" .. r .. "-"
                else
                    v = "0" .. r .. "-"
                end

                if d > 999 then
                    v = v .. d
                elseif d > 99 then
                    v = v .. "0" .. d
                elseif d > 9 then
                    v = v .. "00" .. d
                else
                    v = v .. "00" .. d
                end

                button.RandomL = v

                panelData.Windows[1].Buttons[i] = button
            else
                break
            end
        end

        self:SendPanel(panel, panelData)
    end)
end

-- Closing the panel when you are too far away.
-- This is also done clientside so we don't need to network.
hook.Add("Think", "LCARS.ThinkClose", function()
    local toBeClosed = {}
    
    for panel, panelData in pairs(LCARS.ActivePanels) do
        local pos = panelData.Pos

        local entities = ents.FindInSphere(pos, 200)
        local playersFound = false
        for _, ent in pairs(entities) do
            if ent:IsPlayer() then
                playersFound = true
            end
        end

        if not playersFound then
            table.insert(toBeClosed, panel)
        end
    end

    for _, panel in pairs(toBeClosed) do
        LCARS:DisablePanel(panel)
    end
end)

-- Call FireUser on all Presses
hook.Add("LCARS.Pressed", "LCARS.SimpleScreenPressed", function(ply, panel, panelBrush, i)
    local logicCase = panelBrush:GetParent()
    if IsValid(logicCase) then
        if i >= 1 and i <= 4 then
            panelBrush:Fire("InValue", i)
        end
    else
        if i >= 1 and i <= 4 then
            panelBrush:Fire("FireUser" .. i)
        end
    end
    
    timer.Simple(0.5, function()
        LCARS:DisablePanel(panel)
    end)
end)

-- Receive the pressed event from the client when a user presses his panel.
net.Receive("LCARS.Screens.Pressed", function(len, ply)
    local panelId = net.ReadString()
    local windowId = net.ReadInt(32)
    local buttonId = net.ReadInt(32)

    -- TODO: Replace Sound
    ply:EmitSound("buttons/blip1.wav")
    
    if string.StartWith(panelId, "ENT_") then
        local entId = tonumber(string.sub(panelId, 5))
        local panel = ents.GetByIndex(entId)

        if not IsValid(panel) then return end

        local panelBrush = panel:GetParent()
        hook.Run("LCARS.Pressed", ply, panel, panelBrush, buttonId)
    else
        hook.Run("LCARS.PressedCustom", ply, id, i)
    end
end)
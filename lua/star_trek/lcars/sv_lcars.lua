---------------------------------------
---------------------------------------
--        Star Trek Utilities        --
--                                   --
--            Created by             --
--       Jan 'Oninoni' Ziegler       --
--                                   --
-- This software can be used freely, --
--    but only distributed by me.    --
--                                   --
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--           LCARS | Server          --
---------------------------------------

util.AddNetworkString("Star_Trek.LCARS.Close")
util.AddNetworkString("Star_Trek.LCARS.Open")
util.AddNetworkString("Star_Trek.LCARS.Sync")
util.AddNetworkString("Star_Trek.LCARS.Update")
util.AddNetworkString("Star_Trek.LCARS.Pressed")

-- Closes the given interface.
-- 
-- @param Entity ent
-- @return Boolean Success
-- @return? String error
function Star_Trek.LCARS:CloseInterface(ent)
    if not IsValid(ent) then
        return false, "Invalid Interface Entity!"
    end

    net.Start("Star_Trek.LCARS.Close")
        net.WriteInt(ent:EntIndex(), 32)
    net.Broadcast()

    Star_Trek.LCARS.ActiveInterfaces[ent] = nil

    return true
end

-- Capture closeLcars Input
hook.Add("AcceptInput", "Star_Trek.LCARS.Close", function(ent, input, activator, caller, value)
    if input ~= "CloseLcars" then return end
    
    if Star_Trek.LCARS.ActiveInterfaces[ent] then
        Star_Trek.LCARS:CloseInterface(ent)
    end
end)


-- Retrieves the position and angle of the center of the created interface for that entity.
-- Uses either the origin or an "button" attachment point of the entity.
--
-- @param Entity ent
-- @return Vector interfacePos
-- @return Angle interfaceAngle
function Star_Trek.LCARS:GetInterfacePosAngle(ent)
    local interfacePos = ent:GetPos()
    local interfaceAngle = ent:GetUp():Angle()

    -- If "movedir" keyvalue is set, then override interfaceAngle
    local moveDir = ent:GetKeyValues()["movedir"]
    if isvector(moveDir) then
        interfaceAngle = moveDir:Angle()
    end

    -- If an "button" attachment exists on the model of the entity, then that is used instead.
    local attachmentID = ent:LookupAttachment("button")
    if isnumber(attachmentID) and attachmentID > 0 then
        local attachmentPoint = panel:GetAttachment(attachmentID)
        interfacePos = attachmentPoint.Pos
        interfaceAngle = attachmentPoint.Ang
    else
        -- Model offset, when there is no "button" attachment.
        local modelSetting = self.ModelSettings[ent:GetModel()]
        if istable(modelSetting) then
            interfacePos = interfacePos + interfaceAngle:Forward() * modelSetting.Offset 
        end
    end
    
    interfaceAngle:RotateAroundAxis(interfaceAngle:Right(), -90)
    interfaceAngle:RotateAroundAxis(interfaceAngle:Up(), 90)

    return interfacePos, interfaceAngle
end

-- Opens a given interface at the given console entity.
--
-- @param Entity ent
-- @param Table windows
-- @return Boolean Success
-- @return? String error
function Star_Trek.LCARS:OpenInterface(ent, windows)
    if not IsValid(ent) then 
        return false, "Invalid Interface Entity!"
    end

    if istable(self.ActiveInterfaces[ent]) then
        return true
    end 

    local interfacePos, interfaceAngle = self:GetInterfacePosAngle(ent)
    if not (isvector(interfacePos) and isangle(interfaceAngle)) then
        return false, "Invalid Interface Pos/Angle!"
    end

    if not istable(windows) then
        return false, "No Interface Windows given!"
    end

    local interfaceData = {
        InterfacePos    = interfacePos,
        InterfaceAngle  = interfaceAngle,

        Windows         = windows,
    }

    net.Start("Star_Trek.LCARS.Open")
        net.WriteInt(ent:EntIndex(), 32)
        net.WriteTable(interfaceData)
    net.Broadcast()

    self.ActiveInterfaces[ent] = interfaceData

    return true
end

-- Retrieves the actual interface Entity from the entity that it is triggered from.
--
-- @param Player ply
-- @param Entity triggerEntity
-- @return Boolean Success
-- @return? String/Entity error/ent
function Star_Trek.LCARS:GetInterfaceEntity(ply, triggerEntity)
    if not IsValid(triggerEntity) then
        return false, "Invalid Interface Trigger Entity"
    end
    
    -- If no children, then use trigger Entity.
    local children = triggerEntity:GetChildren()
    if table.Count(children) == 0 then 
        return true, triggerEntity
    end
    
    -- If triggered by non-player, then use trigger Entity.
    if not (IsValid(ply) and ply:IsPlayer()) then
        return true, triggerEntity
    end

    -- Check if Eye Trace Entity is a child.
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) or ent:IsWorld() then
        return false, "Invalid Interface Eye Trace Entity"
    end
    if not table.HasValue(children, ent) then
        return false, "Interface Eye Trace Entity is not a child of the Trigger Entity."
    end

    return true, ent
end

-- Create a window of a given time and the given data.
--
-- @param String windowType
-- @param Vector pos
-- @param Angle angles
-- @param Number scale
-- @param Number widht
-- @param Number height
-- @param? vararg ...
-- @return Boolean Success
-- @return? String/Table error/windowData
function Star_Trek.LCARS:CreateWindow(windowType, pos, angles, scale, width, height, ...)
    local windowFunctions = self.Windows[windowType]
    if not istable(windowFunctions) then
        return false, "Invalid Window Type!"
    end

    local windowData = {
        WindowType = windowType,
        
        WindowPos = pos,
        WindowAngles = angles,

        WindowScale = scale or 20,
        WindowWidth = width or 300,
        WindowHeight = height or 300,
    }

    windowData = windowFunctions.OnCreate(windowData, ...)
    if not istable(windowData) then
        return false, "Invalid Window Data!"
    end

    return true, windowData
end

-- Opening a general Purpose Menu
function Star_Trek.LCARS:OpenMenu()
    local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
    if not success then 
        -- Error Message
        print("[Star Trek] " .. ent)
    end

    local keyValues = ent.LCARSKeyData
    if not istable(keyValues) then
        print("[Star Trek] Invalid Key Values on OpenMenu")
    end

    local buttons = {}
    for i=1,20 do
        local name = keyValues["lcars_name_" .. i]
        if isstring(name) then
            local disabled = keyValues["lcars_disabled_" .. i]

            buttons[i] = {
                Name = name,
                Disabled = disabled,
            }
        else
            break
        end
    end

    local scale = tonumber(keyValues["lcars_scale"])
    local width = tonumber(keyValues["lcars_width"])
    local height = tonumber(keyValues["lcars_height"])

    local success, data = self:CreateWindow("button_list", Vector(), Angle(), scale, width, height, buttons)
    if not success then
        print("[Star Trek] " .. data)
    end

    local windows = {
        [1] = data
    }

    local success, error = self:OpenInterface(ent, windows)
    if not success then
        print("[Star Trek] " .. error)
    end
end

LCARS = LCARS or {}
function LCARS:OpenMenu()
    Star_Trek.LCARS:OpenMenu()
end

-- TODO: Sync on Join Active Interfaces

-- Closing the panel when you are too far away.
-- This is also done clientside so we don't need to network.
hook.Add("Think", "Star_Trek.LCARS.ThinkClose", function()
    local removeInterfaces = {}
    for ent, interfaceData in pairs(Star_Trek.LCARS.ActiveInterfaces) do
        --[[
        if panel.LCARSMenuHasChanged then
            panelData.Windows[1].Buttons = {}

            local panel_brush = panel:GetParent()
            if not IsValid(panel_brush) then 
                panel_brush = panel
            end

            local keyValues = panel_brush.LCARSKeyData
            if istable(keyValues) then
                for i=1,20 do
                    local name = keyValues["lcars_name_" .. i]
                    if isstring(name) then
                        local button = LCARS:CreateButton(name, nil, keyValues["lcars_disabled_" .. i])
                        panelData.Windows[1].Buttons[i] = button
                    else
                        break
                    end
                end
            end

            LCARS:UpdateWindow(panel, 1, panelData.Windows[1])
            panel.LCARSMenuHasChanged = false
        end]]

        local entities = ents.FindInSphere(interfaceData.InterfacePos, 200)
        local playersFound = false
        for _, ent in pairs(entities or {}) do
            if ent:IsPlayer() then
                playersFound = true
            end
        end
        
        if not playersFound then
            table.insert(removeInterfaces, ent)
        end
    end

    for _, ent in pairs(removeInterfaces) do
        Star_Trek.LCARS:CloseInterface(ent)
    end
end)


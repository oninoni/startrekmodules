local function generateButtons(ent, triggerEntity, keyValues)
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

    return buttons
end

-- Opening a general Purpose Menu
function Star_Trek.LCARS:OpenMenu()
    local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
    if not success then 
        -- Error Message
        print("[Star Trek] " .. ent)
    end

    local triggerEntity = ent:GetParent()
    if not IsValid(triggerEntity) then
        triggerEntity = ent
    end

    local keyValues = triggerEntity.LCARSKeyData
    if not istable(keyValues) then
        print("[Star Trek] Invalid Key Values on OpenMenu")
    end

    local buttons = generateButtons(ent, triggerEntity, keyValues)

    local scale = tonumber(keyValues["lcars_scale"])
    local width = tonumber(keyValues["lcars_width"])
    local height = tonumber(keyValues["lcars_height"])

    local success, data = self:CreateWindow("button_list", Vector(), Angle(), scale, width, height, function(windowData, interfaceData, ent, buttonId)
        local triggerEntity = ent:GetParent()
        if not IsValid(triggerEntity) then
            triggerEntity = ent
        end
        
        if buttonId > 4 then
            local name = triggerEntity:GetName()
            local caseEntities = ents.FindByName(name .. "_case")
            for _, caseEnt in pairs(caseEntities) do
                if IsValid(caseEnt) then
                    caseEnt:Fire("InValue", buttonId - 4)
                end
            end
        else
            triggerEntity:Fire("FireUser" .. buttonId)
        end

        local keyValues = triggerEntity.LCARSKeyData
        if istable(keyValues) and keyValues["lcars_keep_open"] then
            return
        end
        
        Star_Trek.LCARS:CloseInterface(ent)
    end, buttons)
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

hook.Add("Think", "Star_Trek.LCARS.BasicInterface", function()
    for ent, interfaceData in pairs(Star_Trek.LCARS.ActiveInterfaces) do
        if IsValid(ent) then
            local triggerEntity = ent:GetParent()
            if not IsValid(triggerEntity) then
                triggerEntity = ent
            end
            
            if triggerEntity.LCARSMenuChanged then
                local buttons = generateButtons(ent, triggerEntity, triggerEntity.LCARSKeyData)

                interfaceData.Windows[1].Buttons = buttons

                Star_Trek.LCARS:UpdateWindow(ent, 1)

                triggerEntity.LCARSMenuChanged = false
            end
        end
    end
end)

-- Detect Updates in _name, _disabled.
hook.Add("Star_Trek.ChangedKeyValue", "Star_Trek.LCARS.BasicInterface", function(ent, key, value)
    if string.StartWith(key, "lcars_name_") or string.StartWith(key, "lcars_disabled_") then
        local keyValues = ent.LCARSKeyData
        if istable(keyValues) and keyValues["lcars_keep_open"] then
            ent.LCARSMenuChanged = true
        end
    end
end)

-- TODO: Get rid of by changing map
LCARS = LCARS or {}
function LCARS:OpenMenu()
    Star_Trek.LCARS:OpenMenu()
end
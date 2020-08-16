LCARS.NextBufferThink = CurTime()

-- TODO: Check Vacancy of Beaming at the Target
-- TODO: Also Check if transport in Progress at that location (No 2 Beams at the same pos at the same time.)

-- TODO: Beam Overflow to Buffer

-- Determine the Objects, that should be beamed.
function LCARS:GetTransporterObjects(panel, window, listWindow)
    local objects = {}
    local objectEntities = {}

    local sourceMode = window.Selected
    local modeName = window.Buttons[sourceMode].Name
    
    for _, button in pairs(listWindow.Buttons) do
        if button.Selected then
            local object = nil

            print(modeName)

            if modeName == "Transporter Pad" then
                -- Beam from Pad
                local pad = button.Data
                local pos = pad:GetPos()
                local attachmentId = pad:LookupAttachment("teleportPoint")
                if attachmentId > 0 then
                    local angPos = pad:GetAttachment(attachmentId)

                    pos = angPos.Pos
                end

                object = {
                    Objects = {},
                    Pad = pad,
                    Pos = pos,
                    TargetCount = 1, -- Only 1 Object per Pad
                }

                local  lowerBounds = pos - Vector(25, 25, 0)
                local higherBounds = pos + Vector(25, 25, 120)
                debugoverlay.Box(pos, -Vector(25, 25, 0), Vector(25, 25, 120), 10, Color(255, 255, 255, 63))

                local entities = ents.FindInBox(lowerBounds, higherBounds)
                for _, ent in pairs(entities) do
                    local name = ent:GetName()
                    if not string.StartWith(name, "TRPad") then
                        table.insert(object.Objects, ent)
                    end
                end
            elseif modeName == "Lifeforms" then
                -- Beam Player
                local targetEnt = button.Data
                local pos = targetEnt:GetPos()
                
                object = {
                    Objects = {targetEnt},
                    Pos = pos,
                    TargetCount = -1, -- Infinite Objects on beaming to player.
                }

                if window.WideBeam then
                    local range = 64
                    local  lowerBounds = pos - Vector(range, range, 0)
                    local higherBounds = pos + Vector(range, range, range * 2)
                    debugoverlay.Box(pos, -Vector(range, range, 0), Vector(range, range, range * 2), 10, Color(255, 255, 255, 63))

                    local entities = ents.FindInBox(lowerBounds, higherBounds)
                    for _, ent in pairs(entities) do
                        if ent:MapCreationID() ~= -1 then continue end

                        local parent = ent:GetParent()
                        if not IsValid(parent) then
                            local phys = ent:GetPhysicsObject()
                            if IsValid(phys) and phys:IsMotionEnabled() and ent ~= targetEnt then
                                table.insert(object.Objects, ent)
                            end
                        end
                    end
                end
            elseif modeName == "Locations" then
                -- Beam from Location
                local targetEntities = button.Data
                
                for i, targetEnt in pairs(targetEntities) do
                    local pos = targetEnt:GetPos()
                
                    object = {
                        Objects = {},
                        Pos = pos,
                        TargetCount = 1,
                    }

                    local range = 32
                    if window.WideBeam then 
                        range = targetEnt.LCARSKeyData["lcars_beamrange"] or 64
                    end

                    local  lowerBounds = pos - Vector(range, range, 0)
                    local higherBounds = pos + Vector(range, range, range * 2)
                    debugoverlay.Box(pos, -Vector(range, range, 0), Vector(range, range, range * 2), 10, Color(255, 255, 255, 63))

                    local entities = ents.FindInBox(lowerBounds, higherBounds)
                    for _, ent in pairs(entities) do
                        if ent:MapCreationID() ~= -1 then continue end

                        local parent = ent:GetParent()
                        if not IsValid(parent) then
                            local phys = ent:GetPhysicsObject()
                            if IsValid(phys) and phys:IsMotionEnabled() then
                                table.insert(object.Objects, ent)
                            end
                        end
                    end

                    if i < #targetEntities then
                        table.insert(objects, object)
                        for _, ent in pairs(object.Objects) do
                            table.insert(objectEntities, ent)
                        end
                    end
                end
            elseif modeName == "Buffer" then
                local targetEnt = button.Data
                local pos = targetEnt:GetPos()

                object = {
                    Objects = {targetEnt},
                    Pos = pos,
                    TargetCount = 0, -- Infinite Objects on beaming to location.
                }
            elseif modeName == "Other Pads" or modeName == "Transporter Pads" then
                -- Beam from Location
                local targetEntities = button.Data
                
                for i, targetEnt in pairs(targetEntities) do
                    local pos = targetEnt:GetPos()
                    local attachmentId = targetEnt:LookupAttachment("teleportPoint")
                    if attachmentId > 0 then
                        local angPos = targetEnt:GetAttachment(attachmentId)

                        pos = angPos.Pos
                    end
                
                    object = {
                        Objects = {},
                        Pos = pos,
                        TargetCount = 1,
                    }

                    local  lowerBounds = pos - Vector(25, 25, 0)
                    local higherBounds = pos + Vector(25, 25, 120)
                    debugoverlay.Box(pos, -Vector(25, 25, 0), Vector(25, 25, 120), 10, Color(255, 255, 255, 63))

                    local entities = ents.FindInBox(lowerBounds, higherBounds)
                    for _, ent in pairs(entities) do
                        local name = ent:GetName()
                        if not string.StartWith(name, "TRPad") then
                            table.insert(object.Objects, ent)
                        end
                    end

                    if i < #targetEntities then
                        table.insert(objects, object)
                        for _, ent in pairs(object.Objects) do
                            table.insert(objectEntities, ent)
                        end
                    end
                end
            end

            table.insert(objects, object)
            for _, ent in pairs(object.Objects) do
                table.insert(objectEntities, ent)
            end

            PrintTable(objectEntities)
        end
    end

    -- Detect any Parenting
    local childEntities = {}
    for _, ent in pairs(objectEntities) do
        local parent = ent:GetParent()
        if parent and IsValid(parent) then
            table.insert(childEntities, ent)
        end
    end

    -- Only Transport the Parent entities (If they are indeed in the selection)
    for _, ent in pairs(childEntities) do
        for _, object in pairs(objects) do
            if table.HasValue(object.Objects, ent) then
                table.RemoveByValue(object.Objects, ent)
            end

            -- TODO: Check for the Parent and add some effect functionality for child Entities
        end
    end

    -- TODO: Check Locations for Transports in progress.

    return objects
end

function LCARS:ActivateTransporter(panelData, panel)
    local leftWindow = panelData.Windows[1]
    local rightWindow = panelData.Windows[2]
    
    local Sources = self:GetTransporterObjects(panel, panelData.Windows[1], panelData.Windows[3])
    
    if rightWindow.BufferTransport and leftWindow.Selected ~= 4 then
        -- Beam to Buffer

        for _, source in pairs(Sources or {}) do
            for _, sourceObject in pairs(source.Objects or {}) do
                table.insert(panel.Buffer, sourceObject)

                self:BeamObject(sourceObject, Vector(), source.Pad, nil, true)
            end
        end
    else
        local Targets = self:GetTransporterObjects(panel, panelData.Windows[2], panelData.Windows[4])

        for _, source in pairs(Sources or {}) do
            for _, sourceObject in pairs(source.Objects or {}) do
                for _, target in pairs(Targets or {}) do
                    target.Count = target.Count or 0

                    if target.TargetCount == -1 or target.Count < target.TargetCount then
                        self:BeamObject(sourceObject, target.Pos, source.Pad, target.Pad, false)

                        if leftWindow.Selected == 4 then
                            table.RemoveByValue(panel.Buffer, sourceObject)
                        end

                        target.Count = target.Count + 1
                        break
                    end
                end
            end
        end

        if leftWindow.Selected == 4 then
            LCARS:CheckBufferMode(panelData, panel)
        end
        
        -- TODO: Beam Overflow to Buffer
    end

    return true
end

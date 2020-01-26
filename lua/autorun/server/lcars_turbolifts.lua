LCARS = LCARS or {}

LCARS.Turbolifts = LCARS.Turbolifts or {}
LCARS.Pods = LCARS.Pods or {}

LCARS.NextTurboliftThink = CurTime()

LCARS.TurboliftMaxTime = 10
LCARS.TurboliftMinTime = 2

-- TODO: Testing
-- Players in targetLift getting moved away. (Pod can't resume CHECK!)
-- Test leaving lift before teleport to pod.

hook.Add("InitPostEntity", "LCARS.PostGamemodeLoaded", function()
    LCARS.Turbolifts = {}
    LCARS.Pods = {}

    local turbolifts = {}

    for _, ent in pairs(ents.GetAll()) do
        if string.StartWith(ent:GetName(), "tlBut") or string.StartWith(ent:GetName(), "TLBut") then
            local number = tonumber(string.sub(ent:GetName(), 6))
            local name = ent.LCARSKeyData["lcars_name"]
            if isstring(name) then
                ent.IsTurbolift = true

                local turboliftData = {
                    Name = name,
                    Entity = ent,
                    InUse = false,
                    Queue = {},
                    LeaveTime = 0,
                    ClosingTime = 0,
                    CloseCallback = nil
                }

                ent.Data = turboliftData

                turbolifts[number] = turboliftData
            end
        elseif string.StartWith(ent:GetName(), "tlPodBut") or string.StartWith(ent:GetName(), "TLPodBut") then
            ent.IsPod = true

            local podData = {
                Entity = ent,
                InUse = false,
                Stopped = false,
                TravelTime = 0,
                TravelTarget = nil,
            }

            ent.Data = podData
            
            table.insert(LCARS.Pods, podData)
        end
    end

    for _, turboliftData in SortedPairs(turbolifts) do
        table.insert(LCARS.Turbolifts, turboliftData)
    end
end)

-- Open a Turbolift Control LCARS Menua.
function LCARS:OpenTurboliftMenu()
    self:OpenMenuInternal(TRIGGER_PLAYER, CALLER, function(ply, panel_brush, panel, screenPos, screenAngle)
        print(ply, panel_brush, panel, screenPos, screenAngle)

        local panelData = {}
        local keyValues = panel_brush.LCARSKeyData

        local name
        if panel_brush.IsTurbolift then
            name = keyValues["lcars_name"]
            
            if not isstring(name) or name == "" then return end
        elseif panel_brush.IsPod then
            name = ""

            local podData = panel_brush.Data
            if podData.Stopped then
                panelData[0] = {
                    Name = "Resume Lift",
                    Disabled = podData.TravelTarget == nil,
                }
            else
                panelData[0] = {
                    Name = "Stop Lift",
                }
            end
        end

        
        for i, turboliftData in pairs(self.Turbolifts) do
            local data = {
                Name = turboliftData.Name,
            }

            if turboliftData.Name == name then
                data.Disabled = true
            end

            panelData[i] = data
        end

        LCARS:SendPanel(ply, panel, panelData, screenPos, screenAngle)
    end)
end

function LCARS:GetUnusedPod()
    for _, podData in pairs(LCARS.Pods) do
        if not podData.InUse then
            podData.InUse = true

            return podData
        end
    end

    return false
end

-- Check Detection not getting everything in pods
function LCARS:GetTurboliftContents(turbolift)
    local objects = {}

    local turboliftModel = turbolift:GetChildren()[1]
    if not IsValid(turboliftModel) then return end

    local attachmentId1 = turboliftModel:LookupAttachment("corner1")
    local attachmentId2 = turboliftModel:LookupAttachment("corner2")

    if isnumber(attachmentId1) and isnumber(attachmentId2) and attachmentId1 ~= -1 and attachmentId2 ~= -1 then
        local attachmentPoint1 = turboliftModel:GetAttachment(attachmentId1)
        local attachmentPoint2 = turboliftModel:GetAttachment(attachmentId2)

        local entities = ents.FindInBox(attachmentPoint1.Pos, attachmentPoint2.Pos)

        for _, ent in pairs(entities or {}) do
            if ent:MapCreationID() == -1 then
                table.insert(objects, ent)
            end
        end
    end

    return objects
end

function LCARS:Teleport(sourceLift, targetLift, objects)
    local sourceLiftModel = sourceLift:GetChildren()[1]
    local targetLiftModel = targetLift:GetChildren()[1]
    if not IsValid(sourceLiftModel) or not IsValid(targetLiftModel) then return end

    for _, ent in pairs(objects) do
        local sourcePos = sourceLiftModel:WorldToLocal(ent:GetPos())
        local targetPos = targetLiftModel:LocalToWorld(sourcePos)

        local sourceAngles
        if ent:IsPlayer() then
            sourceAngles = sourceLiftModel:WorldToLocalAngles(ent:EyeAngles())
        else
            sourceAngles = sourceLiftModel:WorldToLocalAngles(ent:GetAngles())
        end
        
        local targetAngles = targetLiftModel:LocalToWorldAngles(sourceAngles)

        ent:SetPos(targetPos)

        if ent:IsPlayer() then
            ent:SetEyeAngles(targetAngles)
        else
            ent:SetAngles(targetAngles)
        end
    end
end

hook.Add("Think", "LCARS.ThinkTurbolift", function()
    if LCARS.NextTurboliftThink > CurTime() then return end
    LCARS.NextTurboliftThink = CurTime() + 1

    for _, turboliftData in pairs(LCARS.Turbolifts) do
        if turboliftData.LeaveTime > 0 then
            turboliftData.LeaveTime = turboliftData.LeaveTime - 1
            if turboliftData.LeaveTime == 0 then
                turboliftData.InUse = false
            end
        end
        
        if turboliftData.ClosingTime > 0 then
            -- TODO: Add Door Blockage Detection here
            if true then
                turboliftData.ClosingTime = turboliftData.ClosingTime - 1
            else
                turboliftData.ClosingTime = 2
            end
        else
            if isfunction(turboliftData.CloseCallback) then
                turboliftData.CloseCallback()
                turboliftData.CloseCallback = nil
            end
        end
    end

    for _, podData in pairs(LCARS.Pods) do
        if not podData.InUse then continue end

        if podData.Stopped then
            -- Reset empty, stopped pods.
            local podObjects = LCARS:GetTurboliftContents(podData.Entity)
            if table.Count(podObjects) == 0 then
                podData.InUse = false
                podData.Stopped = false
                podData.TravelTime = 0
                podData.TravelTarget = nil
            end

            -- TODO: Stop Animation / Stop Sound Loop

            continue
        else
            if podData.TravelTime > 0 then
                -- TODO: Change Animation / Loop Sound

                podData.TravelTime = podData.TravelTime - 1
            else
                local targetLiftData = podData.TravelTarget
                if not istable(targetLiftData) then continue end
                 
                if not table.HasValue(targetLiftData.Queue, podData) then
                    table.insert(targetLiftData.Queue, podData)
                end

                if targetLiftData.Queue[1] == podData and not targetLiftData.InUse then
                    -- Close + Lock
                    targetLiftData.Entity:Fire("FireUser1")
                    targetLiftData.InUse = true
                    targetLiftData.ClosingTime = 2
                    targetLiftData.CloseCallback = function()
                        table.remove(targetLiftData.Queue, 1)
                        
                        local podObjects = LCARS:GetTurboliftContents(podData.Entity)
                        local targetLiftObjects = LCARS:GetTurboliftContents(targetLiftData.Entity)
                        
                        podData.TravelTime = 0
                        podData.TravelTarget = nil

                        if table.Count(targetLiftObjects) > 0 then
                            LCARS:Teleport(targetLiftData.Entity, podData.Entity, targetLiftObjects)

                            podData.InUse = true
                            podData.Stopped = true
                        else
                            podData.InUse = false
                            podData.Stopped = false
                        end

                        LCARS:Teleport(podData.Entity, targetLiftData.Entity, podObjects)

                        targetLiftData.Entity:Fire("FireUser2")
                        targetLiftData.LeaveTime = 5
                    end
                end
            end
        end
        
    end
end)

hook.Add("LCARS.Pressed", "LCARS.TurboliftPressed", function(ply, currentPanel, currentBrush, i)
    if currentBrush.IsTurbolift then
        local sourceLift = currentBrush
        local sourceLiftData = sourceLift.Data

        local targetLiftData = LCARS.Turbolifts[i]
        if targetLiftData then
            local podData = LCARS:GetUnusedPod()
            
            if podData then
                -- Close + Lock
                sourceLift:Fire("FireUser1")
                sourceLiftData.InUse = true
                sourceLiftData.ClosingTime = 2
                sourceLiftData.CloseCallback = function()
                    local sourceLiftObjects = LCARS:GetTurboliftContents(sourceLift)

                    if table.Count(sourceLiftObjects) > 0 then
                        LCARS:Teleport(sourceLift, podData.Entity, sourceLiftObjects)

                        -- Target Pod and calc travel time.
                        -- TODO: Travel time map?
                        podData.TravelTarget = targetLiftData
                        podData.TravelTime = math.random(LCARS.TurboliftMinTime, LCARS.TurboliftMaxTime)
                    else
                        -- Disable Pod again when there's nobody traveling.
                        podData.InUse = false
                    end

                    podData.Stopped = false

                    -- Unlock
                    sourceLift:Fire("FireUser3")
                    sourceLiftData.InUse = false
                end
            else
                print("Error")
                -- TODO: Error Sound "Turbolift Busy" or sth like that
            end
        end
    elseif currentBrush.IsPod then
        local pod = currentBrush
        local podData = pod.Data

        if i == 0 then
            podData.Stopped = not podData.Stopped
        else
            -- TODO: Handle Queing Aborting

            local targetLiftData = LCARS.Turbolifts[i]
            if targetLiftData then
                podData.InUse = true
                podData.Stopped = false
                podData.TravelTarget = targetLiftData
                podData.TravelTime = math.random(LCARS.TurboliftMinTime, LCARS.TurboliftMaxTime)
            end
        end
    end
end)
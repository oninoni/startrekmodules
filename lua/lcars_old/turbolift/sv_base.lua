
LCARS.NextTurboliftThink = CurTime()

-- TODO: 
-- Testing
-- Players in targetLift getting moved away. (Pod can't resume CHECK!)
-- Test leaving lift before teleport to pod.
-- Add Check for is Door Open/Closed using current Animation and last animation set var. (In Door module)
-- Add Manual Time Delay When opening the door on arrival

-- Setting up Turbolifts
local setupTurbolifts = function()
    LCARS.Turbolifts = {}
    LCARS.Pods = {}

    local turbolifts = {}

    for _, ent in pairs(ents.GetAll()) do
        if string.StartWith(ent:GetName(), "tlBut") or string.StartWith(ent:GetName(), "TLBut") then
            local number = tonumber(string.sub(ent:GetName(), 6))
            if istable(ent.LCARSKeyData) then
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
end

hook.Add("InitPostEntity", "LCARS.TurboliftInitPostEntity", setupTurbolifts)
hook.Add("PostCleanupMap", "LCARS.TurboliftPostCleanupMap", setupTurbolifts)

-- Open a Turbolift Control LCARS Menua.
function LCARS:OpenTurboliftMenu()
    self:OpenMenuInternal(TRIGGER_PLAYER, CALLER, function(ply, panel_brush, panel, screenPos, screenAngle)
        local panelData = {
            Pos = screenPos,
            Type = "Turbolift",
            Windows = {
                [1] = {
                    Pos = screenPos,
                    Angles = screenAngle,
                    Type = "button_list",
                    Scale = 30,
                    Width = 600,
                    Height = 300,
                    Buttons = {}
                }
            }
        }
        local keyValues = panel.LCARSKeyData

        local name
        if panel.IsTurbolift then
            name = keyValues["lcars_name"]

            if not isstring(name) or name == "" then return end
        elseif panel.IsPod then
            name = ""

            local podData = panel.Data
            if podData.Stopped then
                local button = LCARS:CreateButton("Resume Lift", nil, podData.TravelTarget == nil)
                panelData.Windows[1].Buttons[0] = button
            else
                local button = LCARS:CreateButton("Stop Lift", nil, nil)
                panelData.Windows[1].Buttons[0] = button
            end
        end

        for i, turboliftData in pairs(self.Turbolifts) do
            local button = LCARS:CreateButton(turboliftData.Name, nil, turboliftData.Name == name)
            panelData.Windows[1].Buttons[i] = button
        end

        -- debugoverlay.Cross(screenPos, 10, 1, Color(255, 255, 255), true)

        LCARS:SendPanel(panel, panelData)
    end)
end

-- Return an empty Pod and Reserve it.
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

    local attachmentId1 = turbolift:LookupAttachment("corner1")
    local attachmentId2 = turbolift:LookupAttachment("corner2")

    if isnumber(attachmentId1) and isnumber(attachmentId2) and attachmentId1 > 0 and attachmentId2 > 0 then
        local attachmentPoint1 = turbolift:GetAttachment(attachmentId1)
        local attachmentPoint2 = turbolift:GetAttachment(attachmentId2)

        local entities = ents.FindInBox(attachmentPoint1.Pos, attachmentPoint2.Pos)

        for _, ent in pairs(entities or {}) do
            if ent:MapCreationID() == -1 and not (ent:GetClass() == "phys_bone_follower" or ent:GetClass() == "predicted_viewmodel") then
                table.insert(objects, ent)
            end
        end
    end

    return objects
end

-- Teleport all given objects from the sourceLift into the targetLift.
function LCARS:Teleport(sourceLift, targetLift, objects)
    for _, ent in pairs(objects) do
        local sourcePos = sourceLift:WorldToLocal(ent:GetPos())
        local targetPos = targetLift:LocalToWorld(sourcePos)

        local sourceAngles
        if ent:IsPlayer() then
            sourceAngles = sourceLift:WorldToLocalAngles(ent:EyeAngles())
        else
            sourceAngles = sourceLift:WorldToLocalAngles(ent:GetAngles())
        end
        
        local targetAngles = targetLift:LocalToWorldAngles(sourceAngles)

        ent:SetPos(targetPos)

        if ent:IsPlayer() then
            ent:SetEyeAngles(targetAngles)
        else
            ent:SetAngles(targetAngles)
        end
    end
end

-- Think for the Turbolift System.
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
                turboliftData.ClosingTime = 1
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
                podData.TravelPath = nil
            end

            podData.Entity:SetSkin(0)

            continue
        else
            if podData.TravelTime > 0 then
                if podData.TravelPath and podData.TravelPath ~= "" then
                    local currentDirection = podData.TravelPath[podData.TravelTime]
                    if currentDirection == "U" then
                        podData.Entity:SetSkin(1)
                    end
                    if currentDirection == "D" then
                        podData.Entity:SetSkin(2)
                    end
                    if currentDirection == "L" then
                        podData.Entity:SetSkin(3)
                    end
                    if currentDirection == "R" then
                        podData.Entity:SetSkin(4)
                    end
                else
                    podData.Entity:SetSkin(math.random(1, 4))
                end

                podData.TravelTime = podData.TravelTime - 1
            else
                local targetLiftData = podData.TravelTarget
                if not istable(targetLiftData) then continue end
                 
                if not table.HasValue(targetLiftData.Queue, podData) then
                    table.insert(targetLiftData.Queue, podData)
                end

                if targetLiftData.Queue[1] == podData and not targetLiftData.InUse then
                    -- "Dock Animation"
                    podData.Entity:SetSkin(3)
                    
                    -- Close + Lock
                    LCARS:LockTurboliftDoors(targetLiftData.Entity)
                    targetLiftData.InUse = true
                    targetLiftData.ClosingTime = 1
                    targetLiftData.CloseCallback = function()
                        podData.Entity:SetSkin(0)
                        
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

                        LCARS:OpenTurboliftDoors(targetLiftData.Entity)
                        targetLiftData.LeaveTime = 5
                    end
                end
            end
        end
    end
end)

function LCARS:OpenTurboliftDoors(lift)
    local door = lift:GetChildren()[1]
    if IsValid(door) then
        door:Fire("AddOutput", "lcars_locked 0")
        door:Fire("SetAnimation", "open")
    end
end

function LCARS:UnlockTurboliftDoors(lift)
    local door = lift:GetChildren()[1]
    if IsValid(door) then
        door:Fire("AddOutput", "lcars_locked 0")
    end
end

function LCARS:LockTurboliftDoors(lift)
    local door = lift:GetChildren()[1]
    if IsValid(door) then
        door:Fire("AddOutput", "lcars_locked 1")
    end
end

local ud = "UD"
local lr = "LR"

function LCARS:GetDeckNumber(liftData)
    local name = liftData.Name
    if isstring(name) then
        local deckNumber = tonumber(string.sub(name, 6, 7))
        if isnumber(deckNumber) then
            return deckNumber
        end
    end
end

function LCARS:GetTurboliftPath(sourceDeck, targetDeck)
    local deckDiff = math.abs(targetDeck - sourceDeck)
    if deckDiff == 0 then
        -- Same Deck Travel

        -- Calculating time with Advantage! :D
        local travelTime = math.min(
            math.random(LCARS.TurboliftMinTime, LCARS.TurboliftMaxTime),
            math.random(LCARS.TurboliftMinTime, LCARS.TurboliftMaxTime)    
        )
        
        local evadeDirection = ud[math.random(1, 2)]
        if sourceDeck == 1 or sourceDeck == 2 then
            evadeDirection = "D"
        end
        if sourceDeck == 15 then
            evadeDirection = "U"
        end

        local travelPath = "D"
        if evadeDirection == "D" then
            travelPath = "U"
        end

        for i=1,travelTime-2,1 do
            if math.random(1, 2) == 1 or i == 1 then
                travelPath = travelPath .. lr[math.random(1, 2)]
            else
                travelPath = travelPath .. travelPath[#travelPath]
            end
        end

        travelPath = travelPath .. evadeDirection

        return travelPath, #travelPath
    else
        -- Other Deck Travel

        local travelTime = math.min(
            LCARS.TurboliftMaxTime,
            math.max(
                LCARS.TurboliftMinTime,
                math.random(deckDiff + 2, deckDiff * 2)
            )
        )

        local travelDirection = "D"
        if sourceDeck > targetDeck then
            travelDirection = "U"
        end

        local travelPath = ""
        local vertTravelled = 0

        for i=1,travelTime,1 do
            if vertTravelled == deckDiff then
                travelPath = travelPath .. lr[math.random(1, 2)]
            else
                if (travelTime - i) > vertTravelled then
                    if math.random(1, 2) == 1 then
                        travelPath = travelPath .. travelDirection
                        vertTravelled = vertTravelled + 1
                    else
                        travelPath = travelPath .. lr[math.random(1, 2)]
                    end
                else
                    travelPath = travelPath .. travelDirection
                    vertTravelled = vertTravelled + 1
                end
            end
        end
        
        return travelPath, #travelPath
    end
    
    -- Fallback
    return "", self.TurboliftMinTime
end

function LCARS:GetFullTurboliftPath(sourceLiftData, targetLiftData)
    local sourceDeck = LCARS:GetDeckNumber(sourceLiftData)
    local targetDeck = LCARS:GetDeckNumber(targetLiftData)

    return LCARS:GetTurboliftPath(sourceDeck, targetDeck)
end

function LCARS:GetCurrentDeck(targetLiftData, path, travelTimeLeft)
    local totalTravelDistance = 0
    local travelDirection = nil

    for i=1,#path,1 do
        local c = path[i]
        if c == "D" or c == "U" then
            if not travelDirection then
                travelDirection = c
            end
            
            totalTravelDistance = totalTravelDistance + 1
        end
    end

    local traveledDistance = 0
    for i=1,#path-travelTimeLeft,1 do
        local c = path[i]
        if c == "D" or c == "U" then
            traveledDistance = traveledDistance + 1
        end
    end

    local leftOverDistance = totalTravelDistance - traveledDistance
    local targetDeck = LCARS:GetDeckNumber(targetLiftData)

    local currentDeck = targetDeck - leftOverDistance
    if travelDirection == "U" then
        currentDeck = targetDeck + leftOverDistance
    end

    return currentDeck
end

hook.Add("LCARS.PressedCustom", "LCARS.TurboliftPressed", function(ply, panelData, panel, panelBrush, windowId, buttonId)
    if panelData.Type ~= "Turbolift" then return end

    if panel.IsTurbolift then
        local sourceLift = panel
        local sourceLiftData = sourceLift.Data

        local targetLiftData = LCARS.Turbolifts[buttonId]
        if targetLiftData then
            local podData = LCARS:GetUnusedPod()
            if podData then
                -- Close + Lock Doors
                LCARS:LockTurboliftDoors(sourceLift)
                sourceLiftData.InUse = true
                sourceLiftData.ClosingTime = 1
                sourceLiftData.CloseCallback = function()
                    local sourceLiftObjects = LCARS:GetTurboliftContents(sourceLift)

                    if table.Count(sourceLiftObjects) > 0 then
                        LCARS:Teleport(sourceLift, podData.Entity, sourceLiftObjects)

                        -- Target Pod and calc travel time/path.
                        podData.TravelTarget = targetLiftData
                        podData.TravelPath, podData.TravelTime = LCARS:GetFullTurboliftPath(sourceLiftData, targetLiftData)
                    else
                        -- Disable Pod again when there's nobody traveling.
                        podData.InUse = false
                    end

                    podData.Stopped = false

                    -- Unlock
                    LCARS:UnlockTurboliftDoors(sourceLift)
                    sourceLiftData.InUse = false
                end
                            
                timer.Simple(0.5, function()
                    LCARS:DisablePanel(panel)
                end)
            else
                print("Error")
                -- TODO: Error Sound "Turbolift Busy" or sth like that
            end
        end
    elseif panel.IsPod then
        local pod = panel
        local podData = pod.Data

        if buttonId == 0 then
            podData.Stopped = not podData.Stopped
        else
            -- TODO: Handle Queing Aborting

            local targetLiftData = LCARS.Turbolifts[buttonId]
            if targetLiftData then
                podData.InUse = true
                podData.Stopped = false

                local odlTargetDeck = podData.TravelTarget
                local sourceDeck = LCARS:GetCurrentDeck(odlTargetDeck, podData.TravelPath, podData.TravelTime)
                local targetDeck = LCARS:GetDeckNumber(targetLiftData)

                podData.TravelTarget = targetLiftData
                podData.TravelPath, podData.TravelTime = LCARS:GetTurboliftPath(sourceDeck, targetDeck)
            end
        end
                        
        timer.Simple(0.5, function()
            LCARS:DisablePanel(panel)
        end)
    end
end)
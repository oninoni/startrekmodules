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
--           Doors | Server          --
---------------------------------------

Star_Trek.Doors.NextThink = CurTime()
Star_Trek.Doors.Doors = Star_Trek.Doors.Doors or {}

-- Setting up Doors.
local setupDoors = function()
    Star_Trek.Doors.Doors = {}

    for _, ent in pairs(ents.GetAll()) do
        ent.DoorLastSequenceStart = CurTime()

        if ent:GetClass() == "prop_dynamic" and table.HasValue(Star_Trek.Doors.Models, ent:GetModel()) then
            table.insert(Star_Trek.Doors.Doors, ent)
        end
    end
end
hook.Add("InitPostEntity", "Star_Trek.DoorInitPostEntity", setupDoors)
hook.Add("PostCleanupMap", "Star_Trek.DoorPostCleanupMap", setupDoors)

-- Block Doors aborting animations.
hook.Add("AcceptInput", "Star_Trek.BlockDoorIfAlreadyDooring", function(ent, input, activator, caller, value)
    if table.HasValue(Star_Trek.Doors.Doors, ent) and input == "SetAnimation" then
        -- Prevent the same animation again.
        local currentSequence = ent:GetSequence()
        local sequence = ent:LookupSequence(value)
        if sequence and currentSequence and sequence == currentSequence then
            return true
        end

        -- Prevent aborting the animation.
        local duration = ent:SequenceDuration()
        if value == "close" then
            duration = duration + 1
        end
        local diff = CurTime() - (ent.DoorLastSequenceStart + duration)
        if diff < 0 then
            timer.Create("Star_Trek.DoorTimer." .. ent:EntIndex(), diff, 1, function()
                ent:Fire("SetAnimation", value)
            end)

            return true
        end

        timer.Remove("Star_Trek.DoorTimer." .. ent:EntIndex())

        -- Prevent opening a locked door.
        if value == "open" and ent.LCARSKeyData then
            local locked = ent.LCARSKeyData["lcars_locked"]
            if isstring(locked) and locked == "1" then
                return true
            end
        end

        if value == "open" then
            ent.Open = true

            timer.Simple(ent:SequenceDuration(value) / 2, function()
                ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                ent:SetSolid(SOLID_NONE)
            end)
        elseif value == "close" then
            ent.Open = false

            ent:SetCollisionGroup(COLLISION_GROUP_NONE)
            ent:SetSolid(SOLID_VPHYSICS)
        end

        if ent.LCARSKeyData then
            local partnerDoorName = ent.LCARSKeyData["lcars_partnerdoor"]
            if isstring(partnerDoorName) then
                local partnerDoors = ents.FindByName(partnerDoorName)
                for _, partnerDoor in pairs(partnerDoors) do
                    if partnerDoor == ent then continue end

                    partnerDoor:Fire("SetAnimation", value)
                end
            end
        end

        ent.DoorLastSequenceStart = CurTime()
    end
end)

-- Handle being locked. (Autoclose)
hook.Add("Star_Trek.ChangedKeyValue", "Star_Trek.LockDoors", function(ent, key, value)
    if key == "lcars_locked" and isstring(value) and value == "1" and table.HasValue(Star_Trek.Doors.Doors, ent) then
        ent:Fire("SetAnimation", "close")
    end
end)

-- Open door when pressing use on them.
hook.Add("KeyPress", "Star_Trek.OpenDoors", function(ply, key)
    if key == IN_USE then
        local trace = ply:GetEyeTrace()
        local ent = trace.Entity
        if IsValid(ent) and table.HasValue(Star_Trek.Doors.Doors, ent) then
            local distance = trace.HitPos:Distance(ply:EyePos())
            if distance < 64 then
                ent:Fire("SetAnimation", "open")
            end
        end
    end
end)

local function checkPlayers(ent)
    local entities = ents.FindInSphere(ent:GetPos(), 64)
    for _, nearbyEnt in pairs(entities) do
        if nearbyEnt:IsPlayer() then
            local distance = nearbyEnt:EyePos():Distance(ent:GetPos())
            if distance <= 32 then
                return true
            end

            if nearbyEnt:GetEyeTrace().Entity == ent then
                return true
            end
        end
    end
end

local function handleParterDoors(ent)
    local allDoorsFree = true
    local partnerDoorName = ent.LCARSKeyData["lcars_partnerdoor"]
    if isstring(partnerDoorName) then
        local partnerDoors = ents.FindByName(partnerDoorName)
        for _, partnerDoor in pairs(partnerDoors) do
            if checkPlayers(partnerDoor) then
                allDoorsFree = false
            end
        end
    end

    return allDoorsFree
end

-- Think hook for auto-closing the doors.
hook.Add("Think", "Star_Trek.DoorThink", function()
    if Star_Trek.Doors.NextThink > CurTime() then return end
    Star_Trek.Doors.NextThink = CurTime() + 0.2

    for _, ent in pairs(Star_Trek.Doors.Doors or {}) do
        if ent.Open then
            if not checkPlayers(ent) then
                if ent.LCARSKeyData then
                    local allDoorsFree = handleParterDoors(ent)

                    if not allDoorsFree then continue end
                end

                ent:Fire("SetAnimation", "close")
            end

            continue
        end

        if ent.LCARSKeyData and ent.LCARSKeyData["lcars_autoopen"] == "1" and checkPlayers(ent) then
            ent:Fire("SetAnimation", "open")
        end
    end
end)
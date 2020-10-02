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
--   Transporter Patterns | Server   --
---------------------------------------

--      Pattern Data Format:
-- {
-- Entities = {},
--      Table, that contains all of the entities detected from that pattern search.
--      If it is used as a target those entities need to be considered in relation to if the target is valid.
-- Pos = Vector(),
--      Position, where the target can place objects or around, if Multi-Target Mode is used.
-- }

-- Combines a given table of multiple pattern Data tables.
-- 
-- @param Table patterns
-- @return Table patterns
function Star_Trek.Transporter:CleanupPatternList(patterns)
    -- Cleanup Double-Mentions fo entities.
    local patternEntities = {}
    for _, pattern in pairs(patterns) do
        local removeEntities = {}
        for _, ent in pairs(pattern.Entities) do
            if table.HasValue(patternEntities, ent) then
                table.insert(removeEntities, ent)
            else
                table.insert(patternEntities, ent)
            end
        end
        
        for _, removeEnt in pairs(removeEntities) do
            table.RemoveByValue(pattern.Entities, removeEnt)
        end
    end

    -- Determine Entities, that have a parent entity and remove them from their patterns.
    for _, pattern in pairs(patterns) do
        local removeEntities = {}
        for _, ent in pairs(pattern.Entities) do
            local parent = ent:GetParent()
            if parent and IsValid(parent) then
                table.insert(removeEntities, ent)
            end
        end
        
        for _, removeEnt in pairs(removeEntities) do
            table.RemoveByValue(pattern.Entities, removeEnt)
        end
    end

    return patterns
end

-- Returns pattern data from a single transporter pad.
--
-- @param Entity pad
-- @return Table pattern
function Star_Trek.Transporter:GetPatternFromPad(pad)
    local pos = pad:GetPos()
    local attachmentId = pad:LookupAttachment("teleportPoint")
    if attachmentId > 0 then
        pos = pad:GetAttachment(attachmentId).Pos
    end

    pattern = {
        Entities = {},
        Pos = pos,
    }

    local  lowerBounds = pos - Vector(25, 25, 0)
    local higherBounds = pos + Vector(25, 25, 120)
    for _, ent in pairs(ents.FindInBox(lowerBounds, higherBounds)) do
        local name = ent:GetName()
        if not string.StartWith(name, "TRPad") then
            table.insert(pattern.Entities, ent)
        end
    end
    
    --debugoverlay.Box(pos, -Vector(25, 25, 0), Vector(25, 25, 120), 2, Color(255, 255, 255, 63))

    pattern.Pad = pad
    return pattern
end

-- Determines all of the pattern Data Tables for a given Group of transporter Pads.
-- Intended, to be all pads inside of an Transporter Room, etc..
--
-- @param Table pads
-- @return Table patterns
function Star_Trek.Transporter:GetPatternsFromPads(pads)
    local patterns = {}

    for i, pad in pairs(pads) do
        local pattern = self:GetPatternFromPad(pad)
        patterns[i] = pattern
    end

    patterns = self:CleanupPatternList(patterns)

    patterns.SingleTarget = true
    return patterns
end

-- Returns pattern data from a player.
--
-- @param Player ply
-- @param Boolean wideField
-- @return Table pattern
function Star_Trek.Transporter:GetPatternFromPlayer(ply, wideField)
    local pos = ply:GetPos()

    pattern = {
        Entities = {ply},
        Pos = pos,
    }

    if wideField then
        local range = 64
        local  lowerBounds = pos - Vector(range, range, 0)
        local higherBounds = pos + Vector(range, range, range * 2)
        for _, ent in pairs(ents.FindInBox(lowerBounds, higherBounds)) do
            if ent:MapCreationID() ~= -1 then continue end

            local parent = ent:GetParent()
            if not IsValid(parent) then
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) and phys:IsMotionEnabled() and ent ~= targetEnt then
                    table.insert(pattern.Entities, ent)
                end
            end
        end
        
        --debugoverlay.Box(pos, -Vector(range, range, 0), Vector(range, range, range * 2), 2, Color(255, 255, 255, 63))
    end

    return pattern
end

-- Determines all of the pattern Data Tables for a given list of players.
--
-- @param Table players
-- @return Table patterns
function Star_Trek.Transporter:GetPatternsFromPlayers(players, wideField)
    local patterns = {}

    for i, ply in pairs(players) do
        local pattern = self:GetPatternFromPlayer(ply, wideField)
        patterns[i] = pattern
    end

    patterns = self:CleanupPatternList(patterns)

    patterns.SingleTarget = false
    return patterns
end

-- Returns pattern data from a location.
--
-- @param Vector pos
-- @param Boolean wideField
-- @return Table pattern
function Star_Trek.Transporter:GetPatternFromLocation(pos, wideField)
    pattern = {
        Entities = {},
        Pos = pos,
    }

    local range = 32
    if wideField then 
        range = 64
    end

    local  lowerBounds = pos - Vector(range, range, 0)
    local higherBounds = pos + Vector(range, range, range * 2)
    for _, ent in pairs(ents.FindInBox(lowerBounds, higherBounds)) do
        if ent:MapCreationID() ~= -1 then continue end

        local parent = ent:GetParent()
        if not IsValid(parent) then
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) and phys:IsMotionEnabled() then
                table.insert(pattern.Entities, ent)
            end
        end
    end

    --debugoverlay.Box(pos, -Vector(range, range, 0), Vector(range, range, range * 2), 2, Color(255, 255, 255, 63))

    return pattern
end

-- Determines all of the pattern Data Tables for a given list of players.
--
-- @param Table positions
-- @return Table patterns
function Star_Trek.Transporter:GetPatternsFromLocations(positions, wideField)
    local patterns = {}

    for i, pos in pairs(positions) do
        local pattern = self:GetPatternFromLocation(pos, wideField)
        patterns[i] = pattern
    end

    patterns = self:CleanupPatternList(patterns)

    patterns.SingleTarget = false
    return patterns
end

-- Returns pattern buffer data containing the given entity.
--
-- @param Entity ent
-- @return Table pattern
function Star_Trek.Transporter:GetPatternFromBuffer(ent)
    return {
        Entities = {ent},
        Pos = nil,
    }
end

-- Determines all of the pattern Data Tables for a given list of entities.
--
-- @param Table entities
-- @return Table patterns
function Star_Trek.Transporter:GetPatternsFromBuffers(entities)
    local patterns = {}

    for i, ent in pairs(entities) do
        local pattern = self:GetPatternFromBuffer(ent)
        patterns[i] = pattern
    end

    patterns = self:CleanupPatternList(patterns)

    patterns.IsBuffer = true
    return patterns
end
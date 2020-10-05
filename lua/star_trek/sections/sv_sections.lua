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
--         Sections | Server         --
---------------------------------------

function Star_Trek.Sections:GetSection(deck, sectionId)
    local deckData = self.Decks[deck]
    if istable(deckData) then
        local sectionData = deckData.Sections[sectionId]
        if istable(deckData) then
            return sectionData
        end

        return false, "Invalid Section Id!"
    end

    return false, "Invalid Deck!"
end

function Star_Trek.Sections:GetInSection(deck, sectionId, allowMap)
    local sectionData, error = self:GetSection(deck, sectionId)
    if not sectionData then
        return false, error
    end

    local objects = {}

    for _, areaData in pairs(sectionData.Areas) do
        local pos = areaData.Pos
        local min = areaData.Min
        local max = areaData.Max
        local angle = areaData.Angle

        local rotMin = LocalToWorld(pos, angle, min, Angle())
        local rotMax = LocalToWorld(pos, angle, max, Angle())

        local realMin = Vector(math.min(rotMin.x, rotMax.x), math.min(rotMin.y, rotMax.y), math.min(rotMin.z, rotMax.z))
        local realMax = Vector(math.max(rotMin.x, rotMax.x), math.max(rotMin.y, rotMax.y), math.max(rotMin.z, rotMax.z))

        local potentialEnts = ents.FindInBox(realMin, realMax)
        for _, ent in pairs(potentialEnts) do
            if table.HasValue(objects, ent) then continue end
            if not allowMap and ent:MapCreationID() ~= -1 then continue end
            if IsValid(ent:GetParent()) then continue end
            
            local entPos = ent.EyePos and ent:EyePos() or ent:GetPos()
            local localPos = -WorldToLocal(pos, angle, entPos, Angle())
            -- TODO: No idea why there needs to be a "-" here!

            if  localPos.x > min.x and localPos.x < max.x
            and localPos.y > min.y and localPos.y < max.y
            and localPos.z > min.z and localPos.z < max.z then
                table.insert(objects, ent)
            end
        end
    end

    return objects
end

function Star_Trek.Sections:SetupSections()
    self.Decks = {}
    
    for i=1,self.DeckCount,1 do
        self.Decks[i] = {
            Sections = {},
        }
    end

    for _, ent in pairs(ents.GetAll()) do
        local name = ent:GetName()
        if not isstring(name) then continue end

        if not string.StartWith(name, "section") then continue end

        local numberData = string.Split(string.sub(ent:GetName(), 8), "_")
        if not istable(numberData) then continue end

        local deck = tonumber(numberData[1])
        if deck < 1 and deck > self.DeckCount then continue end

        local sectionId = numberData[2]
        local keyValues = ent.LCARSKeyData
        if istable(keyValues) then
            local sectionName = keyValues["lcars_name"]

            self.Decks[deck].Sections[sectionId] = self.Decks[deck].Sections[sectionId] or {
                Name = sectionName,
                Areas = {},
            }

            local pos = ent:GetPos()
            local ang = ent:GetAngles() -- TODO: Check if that actually work with brushes

            local min, max = ent:GetCollisionBounds()

            table.insert(self.Decks[deck].Sections[sectionId].Areas, {
                Pos = pos,
                Angle = Angle(),

                Min = min,
                Max = max,
            })
        end

        ent:Remove()
    end

    hook.Run("Star_Trek.Sections.Loaded")
end

local function setupSections()
    Star_Trek.Sections:SetupSections()
end

hook.Add("InitPostEntity", "Star_Trek.Sections.Setup", setupSections)
hook.Add("PostCleanupMap", "Star_Trek.Sections.Setup", setupSections)
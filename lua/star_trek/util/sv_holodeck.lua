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
--         Holodeck | Server         --
---------------------------------------

-- TODO: Own Module with disintegration code.

-- Compresses players between 2 named brush areas.
--
-- @param String outerName
-- @param String innerName
function Star_Trek.Util:CompressPlayers(outerName, innerName)
    local outer = ents.FindByName(outerName)[1]
    local inner = ents.FindByName(innerName)[1]

    if not IsValid(outer) then return end
    if not IsValid(inner) then return end

    local innerBoundsLow, innerBoundsHigh = inner:GetCollisionBounds()
    local outerBoundsLow, outerBoundsHigh = outer:GetCollisionBounds()

    innerBoundsLow = innerBoundsLow + Vector(32, 32, 0)
    innerBoundsHigh = innerBoundsHigh - Vector(32, 32, 0)

    innerBoundsLow = inner:LocalToWorld(innerBoundsLow)
    innerBoundsHigh = inner:LocalToWorld(innerBoundsHigh)
    outerBoundsLow = outer:LocalToWorld(outerBoundsLow)
    outerBoundsHigh = outer:LocalToWorld(outerBoundsHigh)

    local innerEnts = ents.FindInBox(innerBoundsLow, innerBoundsHigh)
    local outerEnts = ents.FindInBox(outerBoundsLow, outerBoundsHigh)

    for _, ent in pairs(innerEnts) do
        if table.HasValue(outerEnts, ent) then
            table.RemoveByValue(outerEnts, ent)
        else
            Star_Trek:Message(ent .. " is inside the holodeck, but not outside! WTF?")
        end
    end

    for _, ent in pairs(outerEnts) do
        if ent:IsPlayer() then
            local xPos = math.random(innerBoundsLow.x, innerBoundsHigh.x)
            local yPos = math.random(innerBoundsLow.y, innerBoundsHigh.y)

            local pos = Vector(xPos, yPos, innerBoundsLow.z)
            local emptyPos = self:FindEmptyPosWithin(pos, innerBoundsLow, innerBoundsHigh)

            if emptyPos then
                ent:SetPos(emptyPos)
            else
                ent:SetPos(pos)

                Star_Trek:Message("No Empty Pos Found, Dumping into other Player/Object")
            end
        end
    end
end
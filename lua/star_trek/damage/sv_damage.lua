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
--          Damage | Server          --
---------------------------------------

function Star_Trek.Damage:DamageSection(damageType, deck, sectionId)
    local damageTypeData = Star_Trek.Damage.DamageTypes[damageType]
    if not (istable(damageTypeData) and istable(damageTypeData.StaticProps)) then
        return
    end

    local modelList = {}
    for model, staticPropData in pairs(damageTypeData.StaticProps) do
        table.insert(modelList, model)
    end

    local staticProps = Star_Trek.Util:GetStaticPropsByModelList(modelList, function(entry)
        if Star_Trek.Sections:IsInSection(deck, sectionId, entry.Origin) then
            return true
        end

        return false
    end)

    local staticProp = table.Random(staticProps)
    local staticPropModel = staticProp.PropType
    local staticPropData = damageTypeData.StaticProps[staticPropModel]

    local location = table.Random(staticPropData.Locations)

    local ent = ents.Create(damageTypeData.Entity)

    debugoverlay.Axis(staticProp.Origin, staticProp.Angles, 5, 5, true)

    PrintTable(staticProp)
    local pos, ang = LocalToWorld(location.Pos, location.Ang, staticProp.Origin, staticProp.Angles)
    ent:SetPos(pos)
    ent:SetAngles(ang)

    ent:Spawn()

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end
end
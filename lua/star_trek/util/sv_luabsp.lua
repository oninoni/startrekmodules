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
--          LuaBSP |  Server         --
---------------------------------------

function Star_Trek.Util:LoadCurrentMap()
    local mapName = game.GetMap()

    self.MapData = self:LoadMap(mapName)

    self.MapData:LoadStaticProps()
end

function Star_Trek.Util:GetStaticPropsByModel(model)
    local props = {}

    for _, lump_entry in pairs(self.MapData.static_props) do
        for _, entry in pairs(lump_entry.entries) do
            if entry.PropType == model then
                table.insert(props, entry)
            end
        end
    end

    return props
end

function Star_Trek.Util:GetStaticPropsByModeList(modelList)
    local props = {}

    for _, model in pairs(modelList) do
        local modelProps = Star_Trek.Util:GetStaticPropsByModel(model)

        for _, entry in pairs(modelProps) do
            table.insert(props, entry)
        end
    end

    return props
end

function Star_Trek.Util:GetStaticPropsInSphere(pos, range)
    local props = {}

    for _, lump_entry in pairs(self.MapData.static_props) do
        for _, entry in pairs(lump_entry.entries) do
            if entry.Origin:Distance(pos) <= range then
                table.insert(props, entry)
            end
        end
    end

    return props
end

Star_Trek.Util:LoadCurrentMap()

hook.Add("Star_Trek.Sections.Loaded", "SetupStaticProps", function()
    local props = Star_Trek.Util:GetStaticPropsByModeList({
        "models/kingpommes/startrek/voyager/doorframe_104.mdl",
        "models/kingpommes/startrek/voyager/doorframe_128a.mdl",
        "models/kingpommes/startrek/voyager/doorframe_128b.mdl",
        "models/kingpommes/startrek/voyager/doorframe_48.mdl",
        "models/kingpommes/startrek/voyager/doorframe_80.mdl",
        --"models/kingpommes/startrek/voyager/panel_beam1.mdl"
    })

    for deck, deckData in pairs(Star_Trek.Sections.Decks) do
        for sectionId, _ in pairs(deckData.Sections) do
            for _, entry in pairs(props) do
                if Star_Trek.Sections:IsInSection(deck, sectionId, entry.Origin) then
                    entry.Used = true
                end
            end
        end
    end

    for _, entry in pairs(props) do
        if entry.Used then
            debugoverlay.Cross(entry.Origin, 100, 60, Color(0, 255, 0), true)
        else
            debugoverlay.Cross(entry.Origin, 100, 60, Color(255, 0, 0), true)
        end
    end
end)
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
--               Loader              --
---------------------------------------

if not string.StartWith(game.GetMap(), "rp_voyager") then return end

Star_Trek = Star_Trek or {}

local function loadModule(name)
    include("star_trek/" .. name .. "/sh_index.lua")

    print("[Star Trek] Loaded Module \"" .. name .. "\"")
end

hook.Add("PostGamemodeLoaded", "Star_Trek.Load", function()
    Star_Trek.Modules = Star_Trek.Modules or {}

    include("star_trek/config.lua")

    for moduleName, enabled in pairs(Star_Trek.Modules) do
        if enabled then
            loadModule(moduleName)
        end
    end
end)
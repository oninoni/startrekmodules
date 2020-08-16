Star_Trek.LCARS.Windows = {}

function Star_Trek.LCARS:LoadWindow(name)
    WINDOW = {}

    if SERVER then
        AddCSLuaFile("windows/" .. name .. "/client.lua")
        include("windows/" .. name .. "/server.lua")
    end
    if CLIENT then
        include("windows/" .. name .. "/client.lua")
    end

    self.Windows[name] = WINDOW

    print("[Star Trek] Loaded LCARS Window Type \"" .. name .. "\"")
end

function Star_Trek.LCARS:LoadWindows()
    local _, directories = file.Find("star_trek/lcars/windows/*", "LUA")

    for _, windowName in pairs(directories) do
        self:LoadWindow(windowName)
    end
end

Star_Trek.LCARS:LoadWindows()
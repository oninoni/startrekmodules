

if SERVER then
    AddCSLuaFile("cl_portal_window.lua")

    include("sv_portal_window.lua")
end

if CLIENT then
    include("cl_portal_window.lua")
end
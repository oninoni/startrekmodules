

Star_Trek.LCARS = Star_Trek.LCARS or {}

if SERVER then
    AddCSLuaFile("sh_lcars.lua")
    AddCSLuaFile("cl_lcars.lua")

    include("sh_lcars.lua")
    include("sv_lcars.lua")
end

if CLIENT then
    include("sh_lcars.lua")
    include("cl_lcars.lua")
end
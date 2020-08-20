

if SERVER then
    AddCSLuaFile("cl_doors.lua")

    include("sv_config.lua")
    include("sv_doors.lua")
end

if CLIENT then
    include("cl_doors.lua")
end
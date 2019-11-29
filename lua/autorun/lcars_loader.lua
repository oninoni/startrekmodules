

LCARS = LCARS or {}

if CLIENT then
    include("lcars/screens/sh_config.lua")
    include("lcars/screens/sh_colors.lua")

    include("lcars/screens/cl_fonts.lua")
    include("lcars/screens/cl_base.lua")

    include("lcars/screens/windows/cl_button_list.lua")
    include("lcars/screens/windows/cl_transport_slider.lua")


    include("lcars/transporter/cl_base.lua")
end

if SERVER then
    include("lcars/util/sv_base.lua")


    AddCSLuaFile("lcars/screens/sh_config.lua")
    AddCSLuaFile("lcars/screens/sh_colors.lua")

    AddCSLuaFile("lcars/screens/cl_fonts.lua")
    AddCSLuaFile("lcars/screens/cl_base.lua")
    
    AddCSLuaFile("lcars/screens/windows/cl_button_list.lua")
    AddCSLuaFile("lcars/screens/windows/cl_transport_slider.lua")
    
    include("lcars/screens/sh_config.lua")
    include("lcars/screens/sh_colors.lua")
    
    include("lcars/screens/sv_base.lua")


    AddCSLuaFile("lcars/transporter/cl_base.lua")
    include("lcars/transporter/sv_base.lua")

    
    include("lcars/holodeck/sv_base.lua")
end

game.AddParticles( "particles/voyager.pcf" )

PrecacheParticleSystem("beam_out")
PrecacheParticleSystem("beam_in")
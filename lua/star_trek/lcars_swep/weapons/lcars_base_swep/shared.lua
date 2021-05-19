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
--      LCARS Base SWEP | Shared     --
---------------------------------------

SWEP.PrintName = "LCARS Base SWEP"

SWEP.Author = "Oninoni"
SWEP.Contact = "https://einfach-gmod.de"
SWEP.Purpose = "Base Entity, that allows the usage of LCARS Interfaces on the Viewmodel."
SWEP.Instructions = "Use as Base for other Entities."

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Slot = 4
SWEP.SlotPos = 42

SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/weapons/v_bugbait.mdl"
SWEP.WorldModel = ""

SWEP.CustomViewModel = ""
SWEP.CustomViewModelBone = "ValveBiped.Bip01_R_Hand"
SWEP.CustomViewModelOffset = Vector()
SWEP.CustomViewModelAngle = Angle()
SWEP.CustomViewModelScale = 1

SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = ""
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false

SWEP.IsLCARS = true

SWEP.MenuOffset = Vector()
SWEP.MenuAngle = Angle()

SWEP.MenuScale = 50
SWEP.MenuWidth = 300
SWEP.MenuHeight = 400
SWEP.MenuName = "LCARS"

SWEP.Modes = {}
SWEP.DefaultMode = false
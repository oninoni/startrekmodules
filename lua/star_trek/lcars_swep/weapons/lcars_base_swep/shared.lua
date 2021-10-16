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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--      LCARS Base SWEP | Shared     --
---------------------------------------

SWEP.Base = "oni_base"

SWEP.PrintName = "LCARS Base SWEP"

SWEP.Author = "Oninoni"
SWEP.Contact = "Discord: Oninoni#8830"
SWEP.Purpose = "Base Entity, that allows the usage of LCARS Interfaces on the Viewmodel."
SWEP.Instructions = "Use as Base for other Entities."

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.ViewModel = "models/weapons/v_bugbait.mdl"
SWEP.WorldModel = ""

SWEP.HoldType = "slam"

SWEP.BoneManip = {
	["ValveBiped.Bip01_R_Clavicle"] = {
		Ang = Angle(-30, 0, 0),
	},
	["ValveBiped.cube3"] = {
		Pos = Vector(-100, 0, 0),
	},
}

SWEP.CustomViewModel = false
SWEP.CustomViewModelBone = "ValveBiped.Bip01_R_Hand"
SWEP.CustomViewModelOffset = Vector()
SWEP.CustomViewModelAngle = Angle()

SWEP.CustomDrawWorldModel = false
SWEP.CustomWorldModelBone = "ValveBiped.Bip01_R_Hand"
SWEP.CustomWorldModelOffset = Vector()
SWEP.CustomWorldModelAngle = Angle()

SWEP.CustomScale = 1

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
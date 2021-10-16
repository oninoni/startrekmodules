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
--       Damages SWEP | Shared       --
---------------------------------------

SWEP.Base = "lcars_base_swep"

SWEP.PrintName = "Damages SWEP"

SWEP.Author = "Oninoni"
SWEP.Contact = "Discord: Oninoni#8830"
SWEP.Purpose = "Admin Device"
SWEP.Instructions = "Create Damage around the ship."

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Slot = 3
SWEP.SlotPos = 42

SWEP.WorldModel = "models/oninoni/star_trek/props/padd.mdl"

SWEP.CustomViewModel = "models/oninoni/star_trek/props/padd.mdl"
SWEP.CustomViewModelBone = "ValveBiped.Bip01_R_Hand"
SWEP.CustomViewModelOffset = Vector(4, -10.5, -1)
SWEP.CustomViewModelAngle = Angle(-55, -85, 90)

SWEP.CustomDrawWorldModel = true
SWEP.CustomWorldModelBone = "ValveBiped.Bip01_R_Hand"
SWEP.CustomWorldModelOffset = Vector(3, -6, -7)
SWEP.CustomWorldModelAngle = Angle(0, -90, 90)


SWEP.MenuOffset = Vector(0, -1.8, 0.3)
SWEP.MenuAngle = Angle(0, 180, 0)

SWEP.MenuScale = 55
SWEP.MenuWidth = 550
SWEP.MenuHeight = 690
SWEP.MenuName = "DMG PADD"

SWEP.Modes = {
	"damage_selector"
}
SWEP.DefaultMode = "damage_selector"
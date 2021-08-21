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

SWEP.CustomViewModel = "models/nova_canterra/props_items/padd_large.mdl"
SWEP.CustomViewModelOffset = Vector(2, -10, 0)
SWEP.CustomViewModelAngle = Angle(55, 90, -90)

SWEP.WorldModel = "models/nova_canterra/props_items/padd_large.mdl"
SWEP.CustomWorldModelOffset = Vector(4, -5, -3)
SWEP.CustomWorldModelAngle = Angle(0, 90, -90)

SWEP.CustomScale = 1.6

SWEP.Slot = 4
SWEP.SlotPos = 42

SWEP.MenuOffset = Vector(-0.2, 0.8, -0.025)
SWEP.MenuAngle = Angle(0, 0, 0)

SWEP.MenuScale = 43
SWEP.MenuWidth = 325
SWEP.MenuHeight = 540
SWEP.MenuName = "DMG PADD"

SWEP.Modes = {
	"damage_selector"
}
SWEP.DefaultMode = "damage_selector"
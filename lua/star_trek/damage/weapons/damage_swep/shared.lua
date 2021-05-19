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
--       Damages SWEP | Shared       --
---------------------------------------

SWEP.Base = "lcars_base_swep"

SWEP.PrintName = "Damages SWEP"

SWEP.Author = "Oninoni"
SWEP.Contact = "https://einfach-gmod.de"
SWEP.Purpose = "Admin Device"
SWEP.Instructions = "Create Damage around the ship."

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/nova_canterra/props_items/padd_large.mdl"

SWEP.CustomViewModel = "models/nova_canterra/props_items/padd_large.mdl"
SWEP.CustomViewModelOffset = Vector(2, -10, 0)
SWEP.CustomViewModelAngle = Angle(55, 90, -90)
SWEP.CustomViewModelScale = 2

SWEP.Slot = 4
SWEP.SlotPos = 42

SWEP.MenuOffset = Vector(-0.2, 1.05, 0)
SWEP.MenuAngle = Angle(0, 0, 0)

SWEP.MenuScale = 50
SWEP.MenuWidth = 450
SWEP.MenuHeight = 750
SWEP.MenuName = "PADD"

SWEP.Modes = {
	"damage_selector"
}
SWEP.DefaultMode = "damage_selector"
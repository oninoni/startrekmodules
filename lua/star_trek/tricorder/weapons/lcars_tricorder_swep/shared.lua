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
--     Tricorder Entity | Shared     --
---------------------------------------

SWEP.Base = "lcars_base_swep"

SWEP.PrintName = "TR-590 Tricorder X"

SWEP.Author = "Oninoni"
SWEP.Contact = "Discord: Oninoni#8830"
SWEP.Purpose = "Multifunctional device"
SWEP.Instructions = "Select from installed functions using R"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/nova_canterra/props_items/padd_large.mdl"

SWEP.CustomViewModel = "models/nova_canterra/props_items/padd_large.mdl"
SWEP.CustomViewModelOffset = Vector(2, -10, 0)
SWEP.CustomViewModelAngle = Angle(55, 90, -90)

SWEP.CustomDrawWorldModel = true
SWEP.CustomWorldModelOffset = Vector(4, -5, -3)
SWEP.CustomWorldModelAngle = Angle(0, 90, -90)

SWEP.CustomScale = 1.6

SWEP.Slot = 4
SWEP.SlotPos = 42

SWEP.MenuOffset = Vector(1, 0, 0)
SWEP.MenuAngle = Angle(90, 0, 0)

SWEP.MenuScale = 50
SWEP.MenuWidth = 300
SWEP.MenuHeight = 400
SWEP.MenuName = "Tricorder"

SWEP.Modes = {
}
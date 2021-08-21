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
--  LCARS SWEP Mode: Damage | Server --
---------------------------------------

MODE.BaseMode = "base"

MODE.Name = "Damage Selector"
MODE.MenuColor = Star_Trek.LCARS.ColorRed

function MODE:CanActivate(ent)
	return false
end

function MODE:Activate(ent)
	local ply = ent:GetOwner()
	if not IsValid(ply) then
		return false, "Invalid Owner"
	end

	Star_Trek.LCARS:OpenInterface(ply, ent, "damage_selector")

	return true
end

function MODE:Deactivate(ent, callback)
	if istable(ent.Interface) then
		ent.Interface:Close(callback)
		return true
	end

	callback()
	return true
end

function MODE:PrimaryAttack(ent)
	ent:EnableScreenClicker(true)
end

function MODE:SecondaryAttack(ent)
end
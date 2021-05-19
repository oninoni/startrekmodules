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
--  LCARS SWEP Mode: Damage | Server --
---------------------------------------

-- TODO: Implement

MODE.BaseMode = "base"

MODE.Name = "Damage Selector"
MODE.MenuColor = Star_Trek.LCARS.ColorRed

function MODE:CanActivate(ent)
	return false
end

function MODE:Activate(ent)
	return false, "Not Implemented"
end

function MODE:Deactivate(ent, callback)
	callback()
	return false, "Not Implemented"
end

function MODE:PrimaryAttack(ent)
end

function MODE:SecondaryAttack(ent)
end
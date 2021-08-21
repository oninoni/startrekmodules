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
--   LCARS SWEP Mode: Base | Server  --
---------------------------------------

MODE.BaseMode = nil

MODE.Name = "Base"
MODE.MenuColor = Star_Trek.LCARS.ColorBlue

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
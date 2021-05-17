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
--   LCARS SWEP Mode: Base | Server  --
---------------------------------------

MODE.BaseMode = nil

MODE.Name = "Base"
MODE.MenuColor = Star_Trek.LCARS.ColorBlue

function MODE:CanActivate(ent)
	return false
end

function MODE:Activate(ent)
end

function MODE:Deactivate(ent)
end

function MODE:PrimaryAttack(ent)
end

function MODE:SecondaryAttack(ent)
end
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
--        PADD Entity | Server       --
---------------------------------------

function SWEP:Initialize()
	self.Enabled = false
end

function SWEP:Reload()
end

function SWEP:PrimaryAttack()
	Star_Trek.PADD:Enable(self)
end

function SWEP:SecondaryAttack()
end
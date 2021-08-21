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
--     Tricorder Entity | Server     --
---------------------------------------

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
end
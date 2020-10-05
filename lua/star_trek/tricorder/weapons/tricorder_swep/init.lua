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
--     Tricorder Entity | Server     --
---------------------------------------

function SWEP:Reload()

end
function SWEP:PrimaryAttack()
    local trace = self:GetOwner():GetEyeTrace()
    print(trace.Hit, trace.HitPos, trace.Entity)
end
function SWEP:SecondaryAttack()

end
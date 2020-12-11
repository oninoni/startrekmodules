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

	debugoverlay.Cross(trace.HitPos, 10, 2, Color(255, 0, 0), true)

	local entities = ents.FindInSphere(trace.HitPos, 100)
	for _, ent in pairs(entities) do
		debugoverlay.Cross(ent:GetPos(), 10, 2, Color(0, 255, 0), true)
		debugoverlay.Text(ent:GetPos(), ent:GetClass(), 2, false)
	end
end

function SWEP:SecondaryAttack()

end
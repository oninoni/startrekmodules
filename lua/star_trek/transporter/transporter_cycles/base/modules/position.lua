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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--    Transporter Cycle | Position   --
---------------------------------------

if not istable(CYCLE) then Star_Trek:LoadAllModules() return end
local SELF = CYCLE

function SELF:SetPos(pos)
	local ent = self.Entity

	if ent:IsRagdoll() then
		local entPos = ent:GetPos()
		local entAng = ent:GetAngles()

		local pCount = ent:GetPhysicsObjectCount()
		for i = 0, pCount - 1 do
			local phys = ent:GetPhysicsObjectNum(i)

			local offPos, offAng = WorldToLocal(phys:GetPos(), phys:GetAngles(), entPos, entAng)
			local newPos, newAng = LocalToWorld(offPos, offAng, pos, ent:GetAngles())

			phys:SetPos(newPos)
			phys:SetAngles(newAng)

			phys:Wake()
		end
	end

	ent:SetPos(pos)
end

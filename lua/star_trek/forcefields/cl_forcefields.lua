---------------------------------------
---------------------------------------
--         Star Trek Modules         --
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
--       Force Fields | Client       --
---------------------------------------

local SOUND_CUTOFF = 500
local cutOffSquared = SOUND_CUTOFF * SOUND_CUTOFF

timer.Create("Star_Trek.ForceFields.Sound", 2, 0, function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local forceFields = ents.FindByClass("force_field")

	local pos = ply:GetPos()

	local nearByFields = {}
	for _, ent in pairs(forceFields) do
		local distance = pos:DistToSqr(ent:GetPos())
		if distance < cutOffSquared then
			if ent.LoopSound then
				continue
			end

			table.insert(nearByFields, {
				Distance = distance,
				Ent = ent
			})
		else
			if ent.LoopSound then
				ent.LoopSound:Stop()
				ent.LoopSound = nil
			end
		end
	end

	for _, forceFieldData in SortedPairsByMemberValue(nearByFields, "Distance") do
		local ent = forceFieldData.Ent
		ent.LoopSound = CreateSound(ent, "star_trek.force_field_loop")
		ent.LoopSound:Play()
	end
end)
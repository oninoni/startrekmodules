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
--    Force Field Entity | Client    --
---------------------------------------

include("shared.lua")

local SOUND_CUTOFF = 500
local cutOffSquared = SOUND_CUTOFF * SOUND_CUTOFF

timer.Create("Star_Trek.Security.ForceFieldSound", 2, 0, function()
	local forceFields = ents.FindByClass("force_field")

	local pos = LocalPlayer():GetPos()

	local nearByFields = {}
	for _, ent in pairs(forceFields) do
		local distance = pos:DistToSqr(ent:GetPos())
		if distance < cutOffSquared then
			if ent.LoopId ~= nil then
				continue
			end

			table.insert(nearByFields, {
				Distance = distance,
				Ent = ent
			})
		else
			if ent.LoopId ~= nil then
				ent:StopLoopingSound(ent.LoopId)
				ent.LoopId = nil
			end
		end
	end

	for _, forceFieldData in SortedPairsByMemberValue(nearByFields, "Distance") do
		local ent = forceFieldData.Ent

		ent.LoopId = ent:StartLoopingSound("star_trek.force_field_loop")
	end
end)
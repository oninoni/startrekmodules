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
--          Portals | Shared         --
---------------------------------------

function Star_Trek.Portals:IsBlocked(portal)
	local parent = portal:GetParent()

	if not Star_Trek.Doors:IsDoor(parent) then return false end

	if IsValid(parent) then
		local sequenceId = parent:GetSequence()
		if parent.LastSequence ~= sequenceId then
			if sequenceId == parent:LookupSequence("close") then
				parent.DelayRenderDisable = CurTime() + parent:SequenceDuration("close") * 2
			end

			parent.LastSequence = sequenceId -- This needs to go!
		end

		if sequenceId == parent:LookupSequence("open") then
			return false
		end

		if isnumber(parent.DelayRenderDisable) and parent.DelayRenderDisable > CurTime() then
			return false
		end

		return true
	end

	return false
end

hook.Add("wp-trace", "doors-portals", function(portal)
	if portal:GetClass() == "linked_portal_window" then
		return false
	end

	if Star_Trek.Portals:IsBlocked(portal) then
		return false
	end
end)
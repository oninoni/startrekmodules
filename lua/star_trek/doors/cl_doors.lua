hook.Add("wp-shouldrender", "LCARS.HidePortalInDoors", function(portal, exitPortal )
	local camOrigin = LocalPlayer():EyePos()
	local distance = camOrigin:Distance( portal:GetPos() )
	local disappearDist = portal:GetDisappearDist()

	if not (disappearDist <= 0) and distance > disappearDist then return false end

    local parent = portal:GetParent()
    if IsValid(parent) then
        local sequenceId = parent:GetSequence()
        if parent.LastSequence ~= sequenceId then
            if sequenceId == parent:LookupSequence("close") then
                parent.DelayRenderDisable = CurTime() + parent:SequenceDuration("close") * 2
            end

            parent.LastSequence = sequenceId
        end

        if sequenceId == parent:LookupSequence("open") then
            return
        end

        if isnumber(parent.DelayRenderDisable) and parent.DelayRenderDisable > CurTime() then
            return true
        end

        return false, true
    end
end)
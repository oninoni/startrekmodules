
local doorModels = {
	"models/kingpommes/startrek/voyager/door_128a.mdl",
	"models/kingpommes/startrek/voyager/door_128b.mdl",
	"models/kingpommes/startrek/voyager/door_104.mdl",
	"models/kingpommes/startrek/voyager/door_80.mdl",
	"models/kingpommes/startrek/voyager/door_48.mdl",
}

-- Block Doors aborting animations.
hook.Add("AcceptInput", "LCARS.BlockDoorIfAlreadyDooring", function(ent, input, activator, caller, value)
	if table.HasValue(doorModels, ent:GetModel()) then
        if input == "SetAnimation" then
            local sequenceId = ent:GetSequence()
            local newSequenceId = ent:LookupSequence(value)
            
            if sequenceId and newSequenceId and sequenceId == newSequenceId then
                return true
            end
        end
    end
end)

hook.Add("KeyPress", "LCARS.OpenDoors", function(ply, key)
	if key == IN_USE then
		local ent = ply:GetEyeTrace().Entity
		if IsValid(ent) then
			if table.HasValue(doorModels, ent:GetModel()) then
				local distance = ent:GetPos():Distance(ply:GetPos())
				if distance < 100 then
					ent:Fire("SetAnimation", "open")

					timer.Simple(5, function()
						ent:Fire("SetAnimation", "close")
					end)
				end				
			end
		end
	end
end)

hook.Add("Think", "LCARS.DoorThink", function()
	local diff = CurTime() - (LCARS.LastDoorThink or 0)
	if diff > 1 then

	end
	LCARS.LastDoorThink = CurTime()
end)
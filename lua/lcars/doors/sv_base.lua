
LCARS.DoorModels = {
	"models/kingpommes/startrek/voyager/door_128a.mdl",
	"models/kingpommes/startrek/voyager/door_128b.mdl",
	"models/kingpommes/startrek/voyager/door_104.mdl",
	"models/kingpommes/startrek/voyager/door_80.mdl",
	"models/kingpommes/startrek/voyager/door_48.mdl",
}

-- Block Doors aborting animations.
hook.Add("AcceptInput", "LCARS.BlockDoorIfAlreadyDooring", function(ent, input, activator, caller, value)
	if table.HasValue(LCARS.Doors, ent) then
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
		if IsValid(ent) and table.HasValue(LCARS.Doors, ent) then
			local distance = ent:GetPos():Distance(ply:GetPos())
			if distance < 64 then
				ent:Fire("SetAnimation", "open")
				ent.Open = true
			end
		end
	end
end)

local setupDoors = function()
	LCARS.Doors = {}

    for _, ent in pairs(ents.GetAll()) do
		if ent:GetClass() == "prop_dynamic" and table.HasValue(LCARS.DoorModels, ent:GetModel()) then
			table.insert(LCARS.Doors, ent)
		end
	end
end

hook.Add("InitPostEntity", "LCARS.DoorInitPostEntity", setupDoors)
hook.Add("PostCleanupMap", "LCARS.DoorPostCleanupMap", setupDoors)

hook.Add("Think", "LCARS.DoorThink", function()
	local diffTime = CurTime() - (LCARS.LastDoorThink or 0)
	if diffTime > 1 then
		for _, ent in pairs(LCARS.Doors) do
			if ent.Open then
				local entities = ents.FindInSphere(ent:GetPos(), 64)
				local playerFound = false
				for _, nearbyEnt in pairs(entities) do
					if nearbyEnt:IsPlayer() then
						playerFound = true
						return
					end
				end

				if not playerFound then
					ent:Fire("SetAnimation", "close")
					ent.Open = false
				end
			end
		end
		
		LCARS.LastDoorThink = CurTime()
	end
end)
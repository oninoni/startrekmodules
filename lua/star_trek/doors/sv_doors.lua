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
--           Doors | Server          --
---------------------------------------

Star_Trek.Doors.Doors = Star_Trek.Doors.Doors or {}

function Star_Trek.Doors:GetPortalDoor(ent)
	local portal = ent.Portal
	if not IsValid(portal) then
		return
	end

	local targetPortal = portal:GetExit()
	if not IsValid(targetPortal) then
		return
	end

	local partnerDoor = targetPortal.Door
	if not IsValid(partnerDoor) then
		return
	end

	return partnerDoor
end

-- Block Doors aborting animations.
hook.Add("AcceptInput", "Star_Trek.BlockDoorIfAlreadyDooring", function(ent, input, activator, caller, value)
	if Star_Trek.Doors.Doors[ent] and string.lower(input) == "setanimation" then
		value = string.lower(value)

		if value == "idle" then
			return
		end

		-- Prevent the same animation again.
		local currentSequence = ent:GetSequence()
		local sequence = ent:LookupSequence(value)
		if sequence and currentSequence and sequence == currentSequence then
			return true
		end

		-- Prevent aborting the animation.
		local duration = ent:SequenceDuration()
		if value == "close" then
			duration = duration + 1
		end
		local diff = CurTime() - (ent.DoorLastSequenceStart + duration)
		if diff < 0 then
			timer.Create("Star_Trek.DoorTimer." .. ent:EntIndex(), diff, 1, function()
				ent:Fire("SetAnimation", value)
			end)

			return true
		end

		timer.Remove("Star_Trek.DoorTimer." .. ent:EntIndex())

		-- Prevent opening a locked door.
		if value == "open" and ent.LCARSKeyData then
			local locked = ent.LCARSKeyData["lcars_locked"]
			if isstring(locked) and locked == "1" then
				return true
			end
		end

		-- Prevent moving if broken / disabled.
		if Star_Trek.Control:GetStatus("doors", ent.Deck, ent.SectionId) == Star_Trek.Control.INOPERATIVE then
			return true
		end

		-- Prevent moving if partner Door is broken / disabled.
		-- This changes dynamically in for example the holodeck, so its done on runtime.
		local partnerDoor = Star_Trek.Doors:GetPortalDoor(ent)
		if partnerDoor and Star_Trek.Control:GetStatus("doors", partnerDoor.Deck, partnerDoor.SectionId) == Star_Trek.Control.INOPERATIVE then
			return true
		end

		if value == "open" then
			ent.Open = true

			ent:Fire("FireUser1")

			timer.Simple(ent:SequenceDuration(value) / 2, function()
				ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				ent:SetSolid(SOLID_NONE)
			end)
		elseif value == "close" then
			ent.Open = false

			ent:Fire("FireUser2")

			ent:SetCollisionGroup(COLLISION_GROUP_NONE)
			ent:SetSolid(SOLID_VPHYSICS)

			local closeDuration = ent:SequenceDuration(ent:LookupSequence("close"))
			timer.Simple(closeDuration * 2, function()
				if ent:GetSequence() ~= ent:LookupSequence("close") then
					return
				end

				ent:Fire("SetAnimation", "idle")
			end)
		end

		local partnerDoor = Star_Trek.Doors:GetPortalDoor(ent)
		if IsValid(partnerDoor) then
			partnerDoor:Fire("SetAnimation", value)
		end

		ent.DoorLastSequenceStart = CurTime()
	end
end)

-- Handle being locked. (Autoclose)
hook.Add("Star_Trek.ChangedKeyValue", "Star_Trek.LockDoors", function(ent, key, value)
	if key == "lcars_locked" and isstring(value) and Star_Trek.Doors.Doors[ent] then
		-- Prevent locking if broken / disabled
		if Star_Trek.Control:GetStatus("doors", ent.Deck, ent.SectionId) ~= Star_Trek.Control.ACTIVE then
			return
		end

		if value == "1" and ent.Open then
			ent:Fire("SetAnimation", "close")
		end

		local partnerDoor = Star_Trek.Doors:GetPortalDoor(ent)
		if IsValid(partnerDoor) then
			partnerDoor.LCARSKeyData["lcars_locked"] = ent.LCARSKeyData["lcars_locked"]
		end
	end
end)

-- Open door when pressing use on them.
hook.Add("KeyPress", "Star_Trek.OpenDoors", function(ply, key)
	local traceLine = util.RealTraceLine or util.TraceLine

	if key == IN_USE then
		local trace = traceLine({
			start = ply:EyePos(),
			endpos = ply:EyePos() + ply:EyeAngles():Forward() * 128,
			filter = ply,
		})

		local ent = trace.Entity
		if IsValid(ent) and Star_Trek.Doors.Doors[ent] then
			local distance = ent:GetPos():Distance(ply:EyePos())
			if distance < 64 then
				ent:Fire("SetAnimation", "open")
				return
			end
		end
	end
end)

local function checkPlayers(ent)
	local traceLine = util.RealTraceLine or util.TraceLine

	local entities = ents.FindInSphere(ent:GetPos(), 64)
	for _, nearbyEnt in pairs(entities) do
		if nearbyEnt:GetMoveType() == MOVETYPE_NOCLIP then
			continue
		end

		if nearbyEnt:IsNPC() then
			return true
		end

		if nearbyEnt:IsPlayer() then
			local eyePos = nearbyEnt:EyePos()
			local entPos = ent:GetPos()
			entPos[3] = eyePos[3]

			local distance = eyePos:Distance(entPos)
			if distance <= 32 or ent.Open then
				return true
			end

			local trace = traceLine({
				start = nearbyEnt:EyePos(),
				endpos = nearbyEnt:EyePos() + nearbyEnt:EyeAngles():Forward() * 128,
				filter = nearbyEnt,
			})

			if trace.Entity == ent then
				return true
			end
		end
	end
end

Star_Trek.Doors.NextDoorThink = CurTime()

-- Think hook for auto-closing the doors.
hook.Add("Think", "Star_Trek.Doors.DoorThink", function()
	if Star_Trek.Doors.NextDoorThink > CurTime() then return end
	Star_Trek.Doors.NextDoorThink = CurTime() + Star_Trek.Doors.ThinkDelay

	for ent, _ in pairs(Star_Trek.Doors.Doors or {}) do
		if ent.Open then
			local partnerDoor = Star_Trek.Doors:GetPortalDoor(ent)
			if checkPlayers(ent) or (partnerDoor and checkPlayers(partnerDoor)) then
				ent.CloseAt = nil
			else
				if not ent.CloseAt then
					ent.CloseAt = CurTime() + Star_Trek.Doors.CloseDelay
					continue
				end

				if ent.CloseAt > CurTime() then
					continue
				end

				ent:Fire("SetAnimation", "close")
			end

			continue
		end

		if ent.LCARSKeyData and ent.LCARSKeyData["lcars_autoopen"] == "1" and checkPlayers(ent) then
			-- Prevent moving if broken / disabled.
			if Star_Trek.Control:GetStatus("doors", ent.Deck, ent.SectionId) ~= Star_Trek.Control.ACTIVE then
				continue
			end

			-- Prevent moving if partner Door is broken / disabled.
			-- This changes dynamically in for example the holodeck, so its done on runtime.
			local partnerDoor = Star_Trek.Doors:GetPortalDoor(ent)
			if partnerDoor and Star_Trek.Control:GetStatus("doors", partnerDoor.Deck, partnerDoor.SectionId) ~= Star_Trek.Control.ACTIVE then
				continue
			end

			ent:Fire("SetAnimation", "open")
		end
	end
end)

-- Register Door Control Type.
-- Callback opens doors when they are disabled and not locked.
Star_Trek.Control:Register("doors")

-------------
--- Setup ---
-------------

hook.Add("Star_Trek.Sections.Loaded", "Star_Trek.Doors.Setup", function()
	Star_Trek.Doors.Doors = {}

	-- Handle regular doors.
	for _, ent in pairs(ents.GetAll()) do
		if Star_Trek.Doors:IsDoor(ent) then
			ent.DoorLastSequenceStart = CurTime()
			Star_Trek.Doors.Doors[ent] = true

			if string.StartWith(ent:GetModel(), "models/kingpommes/startrek/intrepid/jef_") then
				ent.JeffriesDoor = true
			else
				ent.NormalDoor = true
			end

			local success, deck, sectionId = Star_Trek.Sections:DetermineSection(ent:GetPos())
			if success then
				ent.Deck = deck
				ent.SectionId = sectionId

				local success2, sectionData = Star_Trek.Sections:GetSection(deck, sectionId)
				if success2 then
					sectionData.Doors = sectionData.Doors or {}
					table.insert(sectionData.Doors, ent)
				end
			end

			local sourceEntities = ents.FindInSphere(ent:GetPos(), 8)
			for _, portal in pairs(sourceEntities) do
				if portal:GetClass() ~= "linked_portal_door" then
					continue
				end

				ent.Portal = portal
				portal.Door = ent
			end
		end
	end
end)
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
--         Turbolift | Server        --
---------------------------------------

Star_Trek.Turbolift.NextThink = CurTime()
Star_Trek.Turbolift.Lifts = Star_Trek.Turbolift.Lifts or {}
Star_Trek.Turbolift.Pods  = Star_Trek.Turbolift.Pods  or {}

hook.Add("Star_Trek.Sections.Loaded", "Star_Trek.Turbolift.Setup", function()
	Star_Trek.Turbolift.Lifts = {}
	Star_Trek.Turbolift.Pods = {}

	local lifts = {}
	for _, ent in pairs(ents.GetAll()) do
		if string.StartWith(ent:GetName(), "tlBut") or string.StartWith(ent:GetName(), "TLBut") then
			local number = tonumber(string.sub(ent:GetName(), 6))

			local keyValues = ent.LCARSKeyData
			if istable(keyValues) then
				local name = keyValues["lcars_name"]
				if isstring(name) then
					ent.IsTurbolift = true

					local turboliftData = {
						Name = name,
						ShipId = 0, -- TODO: Implement
						Entity = ent,
						InUse = false,
						Queue = {},
						LeaveTime = 0,
						ClosingTime = 0,
						CloseCallback = nil
					}

					local success, deck, sectionId = Star_Trek.Sections:DetermineSection(ent:GetPos())
					if success then
						ent.Deck = deck
						ent.SectionId = sectionId
					end

					ent.TurboliftData = turboliftData
					lifts[number] = turboliftData
				end
			end
		elseif string.StartWith(ent:GetName(), "tlPodBut") or string.StartWith(ent:GetName(), "TLPodBut") then
			ent.IsPod = true

			local podData = {
				Entity = ent,
				ShipId = 0, -- TODO: Implement
				InUse = false,
				Stopped = false,
				TravelTime = 0,
				TravelTarget = nil,
			}

			ent.TurboliftData = podData
			table.insert(Star_Trek.Turbolift.Pods, podData)
		end
	end

	for i, liftData in SortedPairs(lifts) do
		table.insert(Star_Trek.Turbolift.Lifts, liftData)
	end
end)

Star_Trek.Control:Register("turbolift", function(value, deck, sectionId)
	if value == Star_Trek.Control.ACTIVE then
		return
	end

	if value == Star_Trek.Control.INOPERATIVE and Star_Trek.Turbolift.GetStuck then
		for _, podData in pairs(Star_Trek.Turbolift.Pods) do
			if not podData.InUse then continue end

			Star_Trek.Turbolift:StopPod(nil, podData)
		end
	end
end)

-- Return an empty Pod and Reserve it.
--
-- @return? Table podData
function Star_Trek.Turbolift:GetUnusedPod()
	for _, podData in pairs(self.Pods) do
		if not podData.InUse then
			podData.InUse = true

			return podData
		end
	end

	return false
end

-- Returns all the objects in a given turbolift or pod.
--
-- @param Entity liftEntity
-- @param Table objects
function Star_Trek.Turbolift:GetObjects(liftEntity)
	local objects = {}

	local attachmentId1 = liftEntity:LookupAttachment("corner1")
	local attachmentId2 = liftEntity:LookupAttachment("corner2")

	if isnumber(attachmentId1) and isnumber(attachmentId2) and attachmentId1 > 0 and attachmentId2 > 0 then
		local attachmentPoint1 = liftEntity:GetAttachment(attachmentId1)
		local attachmentPoint2 = liftEntity:GetAttachment(attachmentId2)

		local entities = ents.FindInBox(attachmentPoint1.Pos, attachmentPoint2.Pos)

		for _, ent in pairs(entities or {}) do
			if ent == liftEntity then
				continue
			end

			if table.HasValue(liftEntity:GetChildren(), ent) then
				continue
			end

			if ent:MapCreationID() ~= -1 then
				continue
			end

			local class = ent:GetClass()
			if class == "phys_bone_follower"
			or class == "predicted_viewmodel"
			or class == "force_field" then
				continue
			end

			if hook.Run("Star_Trek.Turbolift.ExcludeTeleport", liftEntity, ent) then
				continue
			end

			table.insert(objects, ent)
		end
	end

	return objects
end

-- Teleport all given objects from the sourceLift into the targetLift.
-- 
-- @param Entity sourceLift
-- @param Entity targetLift
-- @param Table objects
function Star_Trek.Turbolift:Teleport(sourceLift, targetLift, objects)
	for _, ent in pairs(objects) do
		local sourcePos = sourceLift:WorldToLocal(ent:GetPos())
		local targetPos = targetLift:LocalToWorld(sourcePos)

		local sourceAngles
		if ent:IsPlayer() then
			sourceAngles = sourceLift:WorldToLocalAngles(ent:EyeAngles())
		else
			sourceAngles = sourceLift:WorldToLocalAngles(ent:GetAngles())
		end

		local targetAngles = targetLift:LocalToWorldAngles(sourceAngles)

		if ent:IsRagdoll() then
			local entPos = ent:GetPos()
			local entAng = ent:GetAngles()

			local pCount = ent:GetPhysicsObjectCount()
			for i = 0, pCount - 1 do
				local phys = ent:GetPhysicsObjectNum(i)

				local offPos, offAng = WorldToLocal(phys:GetPos(), phys:GetAngles(), entPos, entAng)
				local newPos, newAng = LocalToWorld(offPos, offAng, targetPos, targetAngles)

				phys:SetPos(newPos)
				phys:SetAngles(newAng)

				phys:Wake()
			end
		end

		ent:SetPos(targetPos)
		if ent:IsPlayer() then
			ent:SetEyeAngles(targetAngles)
		else
			ent:SetAngles(targetAngles)
		end
	end
end

-- Start the journey from the given lift to an entity
--
-- @return Boolean canStart
function Star_Trek.Turbolift:StartLift(ply, sourceLift, targetLiftId)
	local sourceLiftData = sourceLift.TurboliftData
	local targetLiftData = self.Lifts[targetLiftId]
	if targetLiftData then
		local targetLift = targetLiftData.Entity
		if not IsValid(targetLift) then
			return false
		end

		if Star_Trek.Control:GetStatus("turbolift", targetLift.Deck, targetLift.SectionId) ~= Star_Trek.Control.ACTIVE then
			return false
		end

		if sourceLiftData.ShipId ~= targetLiftData.ShipId then
			return false
		end

		local podData = self:GetUnusedPod()
		if podData then
			local ent = podData.Entity
			if istable(Star_Trek.Logs) then
				Star_Trek.Logs:StartSession(ent, ply, "Turbolift")
			end

			self:LockDoors(sourceLift)

			sourceLiftData.InUse = true
			sourceLiftData.ClosingTime = 1
			sourceLiftData.CloseCallback = function()
				local sourceLiftObjects = self:GetObjects(sourceLift)
				if table.Count(sourceLiftObjects) > 0 then
					self:Teleport(sourceLift, ent, sourceLiftObjects)

					local filter = RecipientFilter()
					filter:AddAllPlayers()

					podData.LoopSound = CreateSound(ent, "star_trek.turbolift_start")
					podData.LoopSound:Play()

					-- Target Pod and calc travel time/path.
					podData.TravelTarget = targetLiftData
					podData.TravelPath = self:GetFullPath(sourceLiftData, targetLiftData)
					podData.TravelTime = #podData.TravelPath

					if istable(Star_Trek.Logs) then
						Star_Trek.Logs:AddEntry(ent, ply, "Lift heading towards " .. targetLiftData.Name)
						Star_Trek.Logs:AddEntry(ent, ply, "Estimated time of arrival: " .. podData.TravelTime .. "s")
					end
				else
					-- Disable Pod again when there's nobody actually travelling.
					podData.InUse = false

					if istable(Star_Trek.Logs) then
						Star_Trek.Logs:EndSession(ent)
					end
				end

				podData.Stopped = false

				-- Unlock
				self:UnlockDoors(sourceLift)
				sourceLiftData.InUse = false
			end
		else
			return false
		end
	end

	return true
end

function Star_Trek.Turbolift:StopPod(ply, podData)
	podData.Stopped = true

	podData.Entity:EmitSound("star_trek.turbolift_stop")
	podData.LoopSound:Stop()

	if istable(Star_Trek.Logs) then
		Star_Trek.Logs:AddEntry(podData.Entity, ply, "Turbolift halted!")
	end
end

function Star_Trek.Turbolift:ResumePod(ply, podData)
	podData.Stopped = false

	podData.LoopSound = CreateSound(podData.Entity, "star_trek.turbolift_start")
	podData.LoopSound:Play()

	if istable(Star_Trek.Logs) then
		Star_Trek.Logs:AddEntry(podData.Entity, ply, "")
		Star_Trek.Logs:AddEntry(podData.Entity, ply, "Turbolift resumed!")
	end
end

function Star_Trek.Turbolift:TogglePos(ply, pod)
	local podData = pod.TurboliftData
	if podData.Stopped then
		self:ResumePod(ply, podData)
		return false
	else
		self:StopPod(ply, podData)
		return true
	end
end

function Star_Trek.Turbolift:ReRoutePod(ply, pod, targetLiftId)
	local podData = pod.TurboliftData

	local targetLiftData = self.Lifts[targetLiftId]
	if targetLiftData then
		local targetLift = targetLiftData.Entity
		if not IsValid(targetLift) then
			return false
		end

		if Star_Trek.Control:GetStatus("turbolift", targetLift.Deck, targetLift.SectionId) ~= Star_Trek.Control.ACTIVE then
			return false
		end

		if podData.ShipId ~= targetLiftData.ShipId then
			return false
		end

		if not podData.Stopped and istable(Star_Trek.Logs) then
			Star_Trek.Logs:AddEntry(podData.Entity, ply, "Turbolift halted!")
		end

		podData.InUse = true
		self:ResumePod(ply, podData)

		local sourceDeck = podData.CurrentDeck
		local odlTargetDeck = podData.TravelTarget
		if istable(odlTargetDeck) then
			sourceDeck = self:GetCurrentDeck(odlTargetDeck, podData.TravelPath, podData.TravelTime)
		end
		local targetDeck = self:GetDeckNumber(targetLiftData)

		podData.TravelTarget = targetLiftData
		podData.TravelPath = self:GetPath(sourceDeck, targetDeck)
		podData.TravelTime = #podData.TravelPath

		if istable(Star_Trek.Logs) then
			Star_Trek.Logs:AddEntry(podData.Entity, ply, "Lift heading towards " .. targetLiftData.Name)
			Star_Trek.Logs:AddEntry(podData.Entity, ply, "Estimated time of arrival: " .. podData.TravelTime .. "s")
		end

		return true
	end

	return false
end

-- Think for the Turbolift System.
hook.Add("Think", "Star_Trek.Turbolift.Think", function()
	if Star_Trek.Turbolift.NextThink > CurTime() then return end
	Star_Trek.Turbolift.NextThink = CurTime() + 1

	for _, turboliftData in pairs(Star_Trek.Turbolift.Lifts) do
		if turboliftData.LeaveTime > 0 then
			turboliftData.LeaveTime = turboliftData.LeaveTime - 1

			if turboliftData.LeaveTime == 0 then
				turboliftData.InUse = false
			end
		end

		if turboliftData.ClosingTime > 0 then
			if true then
				turboliftData.ClosingTime = turboliftData.ClosingTime - 1
			else
				turboliftData.ClosingTime = 1
			end
		else
			if isfunction(turboliftData.CloseCallback) then
				turboliftData.CloseCallback()
				turboliftData.CloseCallback = nil
			end
		end
	end

	for _, podData in pairs(Star_Trek.Turbolift.Pods) do
		if not podData.InUse then continue end

		if podData.Stopped then
			-- Reset empty, stopped pods.
			local podObjects = Star_Trek.Turbolift:GetObjects(podData.Entity)
			if table.Count(podObjects) == 0 then
				podData.InUse = false
				podData.Stopped = false
				podData.TravelTime = 0
				podData.TravelTarget = nil
				podData.TravelPath = nil

				if istable(Star_Trek.Logs) then
					Star_Trek.Logs:EndSession(podData.Entity)
				end
			end

			podData.Entity:SetSkin(0)

			continue
		else
			if podData.TravelTime > 0 then
				if podData.TravelPath and podData.TravelPath ~= "" then
					local currentDirection = podData.TravelPath[podData.TravelTime]
					if currentDirection == "U" then
						podData.Entity:SetSkin(1)
					end
					if currentDirection == "D" then
						podData.Entity:SetSkin(2)
					end
					if currentDirection == "L" then
						podData.Entity:SetSkin(3)
					end
					if currentDirection == "R" then
						podData.Entity:SetSkin(4)
					end
					if currentDirection == "F" then
						podData.Entity:SetSkin(5)
					end
					if currentDirection == "B" then
						podData.Entity:SetSkin(6)
					end
				else
					podData.Entity:SetSkin(math.random(1, 4))
				end

				podData.TravelTime = podData.TravelTime - 1
			else
				local targetLiftData = podData.TravelTarget
				if not istable(targetLiftData) then continue end

				if not table.HasValue(targetLiftData.Queue, podData) then
					table.insert(targetLiftData.Queue, podData)

					podData.Entity:EmitSound("star_trek.turbolift_stop")
					podData.LoopSound:Stop()
				end

				if targetLiftData.Queue[1] == podData and not targetLiftData.InUse then
					-- "Dock Animation"
					podData.Entity:SetSkin(3)

					-- Close + Lock
					Star_Trek.Turbolift:LockDoors(targetLiftData.Entity)
					targetLiftData.InUse = true
					targetLiftData.ClosingTime = 1
					targetLiftData.CloseCallback = function()
						podData.Entity:SetSkin(0)

						table.remove(targetLiftData.Queue, 1)

						local podObjects = Star_Trek.Turbolift:GetObjects(podData.Entity)
						local targetLiftObjects = Star_Trek.Turbolift:GetObjects(targetLiftData.Entity)

						podData.TravelTime = 0
						podData.TravelTarget = nil

						if table.Count(targetLiftObjects) > 0 then
							Star_Trek.Turbolift:Teleport(targetLiftData.Entity, podData.Entity, targetLiftObjects)

							podData.InUse = true
							podData.Stopped = true
							podData.CurrentDeck = Star_Trek.Turbolift:GetDeckNumber(targetLiftData)
						else
							podData.InUse = false
							podData.Stopped = false

							if istable(Star_Trek.Logs) then
								Star_Trek.Logs:EndSession(podData.Entity)
							end
						end

						Star_Trek.Turbolift:Teleport(podData.Entity, targetLiftData.Entity, podObjects)

						timer.Simple(0.5, function()
							Star_Trek.Turbolift:OpenDoors(targetLiftData.Entity)
						end)
						targetLiftData.LeaveTime = 5
					end
				end
			end
		end
	end
end)

-- Register the default LCARS Types
hook.Add("Star_Trek.ModulesLoaded", "Star_Trek.Turbolift.LoadLogType", function()
	Star_Trek.Logs:RegisterType("Turbolift")
end)
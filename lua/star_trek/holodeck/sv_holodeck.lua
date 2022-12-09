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
--         Holodeck | Server         --
---------------------------------------

Star_Trek.Holodeck.Active = Star_Trek.Holodeck.Active or {}

-- Activate the Holodeck Programm and intialise the custom features.
--
-- @param Number holodeckId
-- @param Number programmId
function Star_Trek.Holodeck:Activate(holodeckId, programmId)
	local holodeckData = {}
	holodeckData.ProgrammId = programmId

	local areaName = "holoProgrammCompress" .. programmId
	local areaEnt = ents.FindByName(areaName)[1]

	if programmId == 1 and not IsValid(areaEnt) then
		areaEnt = ents.FindByName("holoProgrammCompress4")[1]
	end

	if not IsValid(areaEnt) then return end

	local boundsLow, boundsHigh = areaEnt:GetCollisionBounds()
	holodeckData.BoundsLow = areaEnt:LocalToWorld(boundsLow)
	holodeckData.BoundsHigh = areaEnt:LocalToWorld(boundsHigh)

	self.Active[holodeckId] = holodeckData
end

-- Deactivate the Holodeck Programm.
--
-- @param Number programmId
function Star_Trek.Holodeck:Deactivate(programmId)
	local disablingIds = {}
	for holodeckId, holodeckData in pairs(self.Active) do
		if holodeckData.ProgrammId == programmId then
			table.insert(disablingIds, holodeckId)
		end
	end

	for _, holodeckId in pairs(disablingIds) do
		self.Active[holodeckId] = nil
	end
end

hook.Add("Star_Trek.LCARS.BasicPressed", "Star_Trek.Holodeck.DetectToggle", function(ply, interfaceData, buttonId, buttonData)
	local ent = interfaceData.Ent

	local name = ent:GetName()
	if string.StartWith(name, "holoDeckButton") then
		local holodeckId = tonumber(string.sub(name, -1))

		Star_Trek.Holodeck:Activate(holodeckId, buttonId)
	elseif string.StartWith(name, "holoProgrammButton") then
		local programmId = tonumber(string.sub(name, -1))

		Star_Trek.Holodeck:Deactivate(programmId)
	end
end)

-- Compresses players into the entry area of a holodeck.
--
-- @param Number programmId
function Star_Trek.Holodeck:CompressPlayers(programmId)
	local outerName = "holoProgrammCompress" .. programmId
	local innerName = "holoProgrammTele" .. programmId

	local outer = ents.FindByName(outerName)[1]
	local inner = ents.FindByName(innerName)[1]

	-- Temporary fix for map problem.
	if programmId == 1 and not IsValid(outer) then
		outer = ents.FindByName("holoProgrammCompress4")[1]
	end

	if not IsValid(outer) then return end
	if not IsValid(inner) then return end

	local outerBoundsLow, outerBoundsHigh = outer:GetCollisionBounds()
	local innerBoundsLow, innerBoundsHigh = inner:GetCollisionBounds()

	innerBoundsLow = innerBoundsLow + Vector(32, 32, 0)
	innerBoundsHigh = innerBoundsHigh - Vector(32, 32, 0)

	outerBoundsLow = outer:LocalToWorld(outerBoundsLow)
	outerBoundsHigh = outer:LocalToWorld(outerBoundsHigh)
	innerBoundsLow = inner:LocalToWorld(innerBoundsLow)
	innerBoundsHigh = inner:LocalToWorld(innerBoundsHigh)

	local outerEnts = ents.FindInBox(outerBoundsLow, outerBoundsHigh)
	local innerEnts = ents.FindInBox(innerBoundsLow, innerBoundsHigh)

	for _, ent in pairs(innerEnts) do
		if table.HasValue(outerEnts, ent) then
			table.RemoveByValue(outerEnts, ent)
		else
			Star_Trek:Message(ent .. " is inside the holodeck, but not outside! WTF?")
		end

		if ent.HoloMatter then
			Star_Trek.Holodeck:Disintegrate(ent)
			continue
		end

		if ent:IsPlayer() then
			Star_Trek.Holodeck:RemoveHoloWeapons(ent)
			continue
		end
	end

	for _, ent in pairs(outerEnts) do
		if ent.HoloMatter then
			continue
		end
		if ent:MapCreationID() ~= -1 then
			continue
		end
		local phys = ent:GetPhysicsObject()
		if not IsValid(phys) then
			continue
		end

		local xPos = math.random(innerBoundsLow[1], innerBoundsHigh[1])
		local yPos = math.random(innerBoundsLow[2], innerBoundsHigh[2])

		local pos = Vector(xPos, yPos, innerBoundsLow[3])
		local emptyPos = Star_Trek.Util:FindEmptyPosWithin(pos, innerBoundsLow, innerBoundsHigh)

		if isvector(emptyPos) then
			pos = emptyPos
		else
			Star_Trek:Message("No Empty Pos Found, Dumping into other Player/Object")
		end

		local lowerBounds = ent:GetRotatedAABB(ent:OBBMins(), ent:OBBMaxs())
		local zOffset = -lowerBounds.Z + 2 -- Offset to prevent stucking in floor
		ent:SetPos(pos + Vector(0, 0, zOffset))

		if ent:IsPlayer() then
			Star_Trek.Holodeck:RemoveHoloWeapons(ent)
			continue
		end
	end
end

-- Compresses players between 2 named brush areas. (Map Interface Function)
--
-- @param String outerName
-- @param String innerName
function Star_Trek.Util:CompressPlayers(outerName, innerName)
	local programmId1 = tonumber(string.sub(outerName, -1))
	local programmId2 = tonumber(string.sub(innerName, -1))

	if programmId1 == programmId2 then
		Star_Trek.Holodeck:CompressPlayers(programmId1)
	else
		Star_Trek:Message("Unmatching Holodeck Compression Names:", outerName, innerName)
	end
end

function Star_Trek.Holodeck:DisableManually(holodeckId)
	local holodeckData = self.Active[holodeckId]
	if not istable(holodeckData) then
		return
	end

	local programmId = holodeckData.ProgrammId
	local programmEnt = ents.FindByName("holoProgrammButton" .. programmId)[1]

	programmEnt:Fire("FireUser1")
	Star_Trek.Holodeck:Deactivate(programmId)
end

-- Register the holo emitter control type.
Star_Trek.Control:Register("holo", "Holo Emitters", function(value, deck, sectionId)
	-- Shutdown gracefully, if made inactive.
	if value == Star_Trek.Control.INACTIVE then
		if not isnumber(deck) then
			Star_Trek.Holodeck:DisableManually(1)
			Star_Trek.Holodeck:DisableManually(2)

			return
		end

		if deck == 6 then
			if not isnumber(sectionId) then
				Star_Trek.Holodeck:DisableManually(1)
				Star_Trek.Holodeck:DisableManually(2)

				return
			end

			if sectionId == 300 then
				Star_Trek.Holodeck:DisableManually(1)

				return
			end

			if sectionId == 400 then
				Star_Trek.Holodeck:DisableManually(2)

				return
			end
		end
	end
end)

-- Disable Holodeck Controls when inoperative
hook.Add("Star_Trek.LCARS.BasicButtonOverride", "Star_Trek.Holodeck.OverrideControls", function(ent, buttons)
	local name = ent:GetName()
	if not (string.StartWith(name, "holoDeckButton") or string.StartWith(name, "holoProgrammButton")) then
		return
	end

	local success, deck, sectionId = Star_Trek.Sections:DetermineSection(ent:GetPos())
	if not success then
		return
	end

	local status = Star_Trek.Control:GetStatus("holo", deck, sectionId)
	if status ~= Star_Trek.Control.ACTIVE then
		for _, buttonData in pairs(buttons) do
			buttonData.Disabled = true
		end
	end
end)
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

local props_in_programs = {The_Void = {}, Wasteland_Canyon = {}, Holo_Lab = {} }

-- Activate the Holodeck Programm and intialise the custom features.
--
-- @param Number holodeckId
-- @param Number programmId
function Star_Trek.Holodeck:Activate(holodeckId, programmId)
	local holodeckData = {}
	holodeckData.ProgrammId = programmId

	local areaName = "holoProgrammCompress" .. programmId
	local areaEnt = ents.FindByName(areaName)[1]
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
	hook.Run("Star_Trek.Holodeck.Remove_props", programmId)
end

hook.Add("Star_Trek.LCARS.BasicPressed", "Test", function(ply, interfaceData, buttonId)
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
	end

	for _, ent in pairs(outerEnts) do
		if ent:IsPlayer() then
			local xPos = math.random(innerBoundsLow[1], innerBoundsHigh[1])
			local yPos = math.random(innerBoundsLow[2], innerBoundsHigh[2])

			local pos = Vector(xPos, yPos, innerBoundsLow[3])
			local emptyPos = Star_Trek.Util:FindEmptyPosWithin(pos, innerBoundsLow, innerBoundsHigh)

			if emptyPos then
				ent:SetPos(emptyPos)
			else
				ent:SetPos(pos)

				Star_Trek:Message("No Empty Pos Found, Dumping into other Player/Object")
			end
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

hook.Add("Star_Trek.Holodeck.Add_prop", "Star_Trek.Holodeck.Add_prop", function(ent, programID)
	if programID == 1 then program = "The_Void"
	elseif programID == 2 then program = "Wasteland_Canyon"
	elseif programID == 3 then program = "Holo_Lab"
	else print("ERROR in sv_holodeck.lua: Uknown holodeck program") end
	table.insert(props_in_programs[program], ent)
end)

hook.Add("Star_Trek.Holodeck.Remove_props", "Star_Trek.Holodeck.Remove_props", function(programID)
	if programID == 1 then program = "The_Void"
	elseif programID == 2 then program = "Wasteland_Canyon"
	elseif programID == 3 then program = "Holo_Lab"
	else print("ERROR in sv_holodeck.lua: Uknown holodeck program") end
	local props =  props_in_programs[program]
	for i = 1, table.Count(props) do
		local ent = table.remove(props, 1)
		if not IsValid(ent) then continue end
		Star_Trek.Holodeck:Disintegrate(ent)
	end
end)

hook.Add("PreUndo", "Star_Trek.Holodeck.Remove_before_undo", function(undo_table)
	local has_holomatter = false
	for key, ent in ipairs(undo_table.Entities) do
		if not ent.HoloMatter then continue end
		has_holomatter = true
		local prop_found = false
		for i = 1, table.Count(props_in_programs) do
			if prop_found then break end
			if i == 1 then program = "The_Void"
			elseif i == 2 then program = "Wasteland_Canyon"
			elseif i == 3 then program = "Holo_Lab"
			else print("ERROR in sv_holodeck.lua: Uknown holodeck program") end
			local props = props_in_programs[program]
			for key, prop in ipairs(props) do
				if ent == prop then 
					table.remove(props, key)
					prop_found = true
					break
				end
			end
		end
		Star_Trek.Holodeck:Disintegrate(ent)
	end
	if has_holomatter then return false end
end)
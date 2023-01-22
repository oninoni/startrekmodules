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
--        Holomatter | Server        --
---------------------------------------

-- Disintegrate the given object as a deactivating Holodeck Object.
--
-- @param Entity ent
util.AddNetworkString("Star_Trek.Holodeck.Disintegrate")
function Star_Trek.Holodeck:Disintegrate(ent, inverted)
	if not IsValid(ent) then
		return
	end

	net.Start("Star_Trek.Holodeck.Disintegrate")
		net.WriteInt(ent:EntIndex(), 32)
		net.WriteBool(inverted)
	net.Broadcast()

	local oldMode = ent:GetRenderMode()
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:EmitSound("star_trek.hologram_failure")


	local color = ent:GetColor()

	if inverted then
		ent:SetColor(ColorAlpha(color, 0))
	end

	local timerName = "Star_Trek.Holodeck.Disintegrate." .. ent:EntIndex()
	timer.Create(timerName, 1, 1, function()
		if not IsValid(ent) then return end
		if inverted then
			ent:SetRenderMode(oldMode)
			ent:SetColor(color)
		else
			ent:Remove()
		end
	end)
end

function Star_Trek.Holodeck:IsInArea(ent, pos)
	if not IsValid(ent) then
		return false
	end

	local min, max = ent:GetCollisionBounds()
	min = ent:LocalToWorld(min)
	max = ent:LocalToWorld(max)

	if  min.x <= pos.x and max.x >= pos.x
	and min.y <= pos.y and max.y >= pos.y
	and min.z <= pos.z and max.z >= pos.z then
		return true
	end

	return false
end

function Star_Trek.Holodeck:IsInHolodeckProgramm(pos)
	local e2 = ents.FindByName("holoProgrammCompress2")[1]
	if Star_Trek.Holodeck:IsInArea(e2, pos) then
		return true
	end

	local e3 = ents.FindByName("holoProgrammCompress3")[1]
	if Star_Trek.Holodeck:IsInArea(e3, pos) then
		return true
	end

	local e4 = ents.FindByName("holoProgrammCompress4")[1]
	if Star_Trek.Holodeck:IsInArea(e4, pos) then
		return true
	end

	return false
end

hook.Add("OnEntityCreated", "Star_Trek.Holodeck.DetectHolomatter", function(ent)
	timer.Simple(0, function()
		if not IsValid(ent) then return end
		if ent:MapCreationID() ~= -1 then return end

		local owner = ent:GetOwner()
		if IsValid(owner) then
			return
		end

		local phys = ent:GetPhysicsObject()
		if not IsValid(phys) and not ent:IsWeapon() then
			return
		end

		local pos = ent:GetPos()
		if Star_Trek.Holodeck:IsInHolodeckProgramm(pos) then
			ent.HoloMatter = true

			Star_Trek.Holodeck:Disintegrate(ent, true)
		end
	end)
end)

hook.Add("Star_Trek.Transporter.OverrideCanBeam", "Star_Trek.Holodeck.OverrideCanBeam", function(ent)
	if ent.HoloMatter then
		return false
	end
end)

-- Remove all holo weapons from player
-- @param Player ply
function Star_Trek.Holodeck:RemoveHoloWeapons(ply)
	local playSound = false

	for _, weapon in pairs(ply:GetWeapons()) do
		if weapon.HoloMatter then
			-- Not using Star_Trek.Holodeck:Disintegrate, because it does not work correctly.
			-- No sound plays and there is a delay before it removes the weapon.
			weapon:Remove()

			playSound = true
		end
	end

	if playSound then
		ply:EmitSound("star_trek.hologram_failure")
	end
end

hook.Add("wp-teleport", "Star_Trek.Holodeck.Disintegrate", function(self, ent)
	local portalName = self:GetName()
	if not string.StartWith(portalName, "holoProgrammPortal") then
		return
	end

	if ent.HoloMatter then
		Star_Trek.Holodeck:Disintegrate(ent)
		return
	end

	if ent:IsPlayer() then
		Star_Trek.Holodeck:RemoveHoloWeapons(ent)
	end
end)

hook.Add("Star_Trek.Transporter.PreTransportObject", "Star_Trek.Holodeck.Disintegrate", function(cycleType, ent, targetPos, skipDemat, skipRemat, callback)
	if not IsValid(ent) then
		return
	end

	if ent.HoloMatter then
		Star_Trek.Holodeck:Disintegrate(ent)
		return
	end

	if ent:IsPlayer() then
		Star_Trek.Holodeck:RemoveHoloWeapons(ent)
	end
end)

-- Record entity door data.
hook.Add("Star_Trek.Sensors.ScanEntity", "Star_Trek.Holodeck.Check", function(ent, scanData)
	if ent.HoloMatter then
		scanData.HoloMatter = true
	end
end)

-- Output the door data on a tricorder
hook.Add("Star_Trek.Tricorder.AnalyseScanData", "Star_Trek.Holodeck.Output", function(ent, owner, scanData)
	if scanData.HoloMatter then
		Star_Trek.Logs:AddEntry(ent, owner, "Holographic Matter", Star_Trek.LCARS.ColorRed, TEXT_ALIGN_LEFT)
	end
end)

hook.Add("PreUndo", "Star_Trek.Holodeck.PreUndo", function(undoTable)
	local undoEntites = undoTable.Entities

	local toBeRemoved = {}
	for _, ent in ipairs(undoEntites) do
		if ent.HoloMatter then
			Star_Trek.Holodeck:Disintegrate(ent)
			table.insert(toBeRemoved, ent)
		end
	end

	for _, ent in ipairs(toBeRemoved) do
		table.RemoveByValue(undoEntites, ent)
	end

	-- Add Sacrificial Entity.
	if table.Count(undoEntites) == 0 then
		table.insert(undoEntites, ents.Create("prop_dynamic"))
	end
end)
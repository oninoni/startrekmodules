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

	if inverted then
		local color = ent:GetColor()
		ent:SetColor(ColorAlpha(color, 0))
	end

	local timerName = "Star_Trek.Holodeck.Disintegrate." .. ent:EntIndex()
	timer.Create(timerName, 1, 1, function()
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

		local phys = ent:GetPhysicsObject()
		if not IsValid(phys) then
			return
		end

		if hook.Run("Star_Trek.Holodeck.DetectHolomatter", ent) then
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

hook.Add("wp-teleport", "Star_Trek.Holodeck.Disintegrate", function(self, ent)
	if ent.HoloMatter then
		Star_Trek.Holodeck:Disintegrate(ent)
	end
end)
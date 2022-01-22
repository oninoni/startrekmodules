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
--        Transporter | Server       --
---------------------------------------

hook.Add("PlayerCanPickupItem", "Star_Trek.Transporter.PreventPickup", function(ply, ent)
	for _, transportData in pairs(Star_Trek.Transporter.ActiveTransports) do
		if transportData.Object == ent then return false end
	end

	if ent.Replicated and not (ply:KeyDown(IN_USE) and ply:GetEyeTrace().Entity == ent) then
		return false
	end
end)

hook.Add("PlayerCanPickupWeapon", "Star_Trek.Transporter.PreventPickup", function(ply, ent)
	for _, transportData in pairs(Star_Trek.Transporter.ActiveTransports) do
		if transportData.Object == ent then return false end
	end

	if ent.Replicated and not (ply:KeyDown(IN_USE) and ply:GetEyeTrace().Entity == ent) then
		return false
	end
end)

hook.Add("PlayerDeathThink", "Star_Trek.Transporter.BufferReset", function(ply)
	if table.HasValue(Star_Trek.Transporter.Buffer.Entities, ply) then
		ply:Freeze(false)
		table.RemoveByValue(Star_Trek.Transporter.Buffer.Entities, ply)
	end
end)

hook.Add("PlayerSpawn", "Star_Trek.Transporter.BufferReset", function(ply)
	if table.HasValue(Star_Trek.Transporter.Buffer.Entities, ply) then
		ply:Freeze(false)

		table.RemoveByValue(Star_Trek.Transporter.Buffer.Entities, ply)
	end
end)

timer.Create("Star_Trek.Transporter.BufferThink", 1, 0, function()
	local removeFromBuffer = {}

	for _, ent in pairs(Star_Trek.Transporter.Buffer.Entities) do
		if ent.BufferQuality <= 0 then
			table.insert(removeFromBuffer, ent)

			if ent:IsPlayer() then
				Star_Trek.Transporter:BeamObject(ent, Star_Trek.Transporter.Buffer.Pos, nil, nil)
				ent:Kill()
			else
				SafeRemoveEntity(ent)
			end
		end

		ent.BufferQuality = ent.BufferQuality - 1

		if ent.BufferQuality < 100 then
			local maxHealth = ent:GetMaxHealth()
			if maxHealth > 0 then
				local health = math.min(ent:Health(), maxHealth * (ent.BufferQuality / 100))
				ent:SetHealth(health)
			end
		end
	end

	for _, ent in pairs(removeFromBuffer) do
		table.RemoveByValue(Star_Trek.Transporter.Buffer.Entities, ent)
	end
end)
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
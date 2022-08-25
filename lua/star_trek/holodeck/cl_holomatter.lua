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
--        Holomatter | Client        --
---------------------------------------

net.Receive("Star_Trek.Holodeck.Disintegrate", function()
	local entIndex = net.ReadInt(32)

	local inverted = net.ReadBool()

	local time = 0
	local timerName = "Star_Trek.Holodeck.Disintegrate." .. entIndex
	timer.Create(timerName, 0, 0, function()
		time = time + FrameTime()

		local ent = Entity(entIndex)
		if IsValid(ent) then
			local alpha = (1 - time) * 512
			if time > 1 then
				alpha = 0
			else
				alpha = alpha + math.random(-32, 32)
			end

			if inverted then
				alpha = 255 - alpha
			end

			ent:SetColor(ColorAlpha(ent:GetColor(), alpha))

			for _, child in pairs(ent:GetChildren()) do
				child:SetRenderMode(RENDERMODE_TRANSALPHA)
				child:SetColor(ColorAlpha(child:GetColor(), alpha))
			end
		end

		if time > 1 then
			timer.Remove(timerName)
		end
	end)
end)
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
--        Holomatter | Client        --
---------------------------------------

net.Receive("Star_Trek.Holodeck.Disintegrate", function()
	local ent = net.ReadEntity()

	if not IsValid(ent) then
		return
	end

	local time = 0

	local timerName = "Star_Trek.Holodeck.Disintegrate." .. ent:EntIndex()
	timer.Create(timerName, 0, 0, function()
		time = time + FrameTime()

		if not IsValid(ent) or time > 1 then
			ent:SetColor(Color(255, 255, 255, 0))

			timer.Remove(timerName)
		else
			local alpha = (1 - time) * 512
			alpha = alpha + math.random(-32, 32)

			ent:SetColor(Color(255, 255, 255, alpha))
		end
	end)
end)
---------------------------------------
---------------------------------------
--        Star Trek Utilities        --
--                                   --
--            Created by             --
--       Jan "Oninoni" Ziegler       --
--                                   --
-- This software can be used freely, --
--    but only distributed by me.    --
--                                   --
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--         FOV Util | Client         --
---------------------------------------

function Star_Trek.Util:GetFOV()
	local topVector = gui.ScreenToVector(ScrW() * 0.5, 0)
	topVector:Normalize()
	local botVector = gui.ScreenToVector(ScrW() * 0.5, ScrH() - 1)
	botVector:Normalize()

	local fov = math.acos(topVector:Dot(botVector))
	fov = fov / math.pi * 180

	return fov
end
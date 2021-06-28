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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--       World Render | Server       --
---------------------------------------

-- Temporary! Remove the Skybox Testing Spheres.
hook.Add("InitPostEntity", "Star_Trek.World.RemoveMapThings", function()
	for _, ent in pairs(ents.FindByModel("models/hunter/misc/sphere075x075.mdl")) do
		ent:Remove()
	end
end)
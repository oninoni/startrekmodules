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
--          Skybox | Client          --
---------------------------------------

local SCALE = 10000
local COUNT = 5000
local SPEED = 4000
local OFFSET = 2 * SCALE * COUNT / SPEED
Star_Trek.Skybox.Stars = {}

hook.Add("PreDrawSkyBox", "Star_Trek.Skybox.Render", function(...)
	--[[
	while (table.Count(Star_Trek.Skybox.Stars) >= COUNT) do
		table.remove(Star_Trek.Skybox.Stars, 1)
	end

	table.insert(Star_Trek.Skybox.Stars, Vector(-OFFSET, (math.random() - 0.5) * SCALE, (math.random()  - 0.5) * SCALE))

	render.SetColorMaterial()

	for _, pos in pairs(Star_Trek.Skybox.Stars) do
		local p = LocalPlayer():GetPos() + pos
		render.DrawLine(p, p + Vector(50, 0, 0), Color(255, 255, 255))

		pos[1] = pos[1] + FrameTime() * SPEED
	end

	return true]]
end)
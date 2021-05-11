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
--        Render Map | Client        --
---------------------------------------

-- This is a Mapping Tool, not used in gameplay.

local SCALE = 1
local RESOLUTION = 1024

local ZOFFSET = 10
local ZFAR = 20

local function renderMapPart(origin, x, y)
	local texture = GetRenderTarget("LCARS_" .. RESOLUTION .. "_" .. x .. "_" .. y, RESOLUTION, RESOLUTION)
	local pos = origin + Vector(x * RESOLUTION, y * RESOLUTION, ZOFFSET)
	print(pos)

	render.EnableClipping(false)
	render.SetRenderTarget(texture)
		render.RenderView({
			origin = pos,
			angles = Vector(0, 0, -1):AngleEx(Vector(1, 0, 0)),
			x = 0,
			y = 0,
			w = RESOLUTION,
			h = RESOLUTION,
			aspectratio = 1,
			drawhud = false,
			drawmonitors = false,
			drawviewmodel = false,
			ortho = {
				left = -SCALE * RESOLUTION / 2,
				right = SCALE * RESOLUTION / 2,
				top = -SCALE * RESOLUTION / 2,
				bottom = SCALE * RESOLUTION / 2,
			},
			znear = 1,
			zfar = ZFAR,
			bloomtone = false,
		})

		local data = render.Capture({
			format = "png",
			x = 0,
			y = 0,
			w = RESOLUTION,
			h = RESOLUTION,
			alpha = false,
		})

		file.Write("LCARS_" .. RESOLUTION .. "_" .. x .. "_" .. y .. ".png", data)
	render.PopRenderTarget()
	render.EnableClipping(true)
end

concommand.Add("lcars_rendermap", function(ply, cmd, args, argStr)
	--RunConsoleCommand("mat_fullbright", 1)
	print("Please Unpause the game, to render the images.")

	local xMax = args[1]
	local yMax = args[2]

	timer.Simple(0, function()
		for x = 1, xMax do
			local xPos = x - (xMax * 0.5) - 0.5
			for y = 1, yMax do
				local yPos = y - (yMax * 0.5) - 0.5

				renderMapPart(ply:GetPos(), xPos, yPos)
			end
		end

		RunConsoleCommand("mat_fullbright", 0)
	end)
end)
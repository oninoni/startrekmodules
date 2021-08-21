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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--        Render Map | Client        --
---------------------------------------

-- This is a Mapping Tool, not used in gameplay.

local SCALE = 3
local RESOLUTION = 1024

local ZOFFSET = 200
local ZSLIVER = 10

local mapTextureName = "LCARS_MAP_" .. RESOLUTION * SCALE
Star_Trek.Util.MapTexture = GetRenderTarget(mapTextureName, RESOLUTION * SCALE, RESOLUTION * SCALE)
Star_Trek.Util.MapMaterial = CreateMaterial(mapTextureName, "UnlitGeneric", {
	["$basetexture"] = mapTextureName,
})

local saveTextureName = "LCARS_SAVE_" .. RESOLUTION
Star_Trek.Util.SavingTexture = GetRenderTarget(saveTextureName, RESOLUTION, RESOLUTION)
Star_Trek.Util.SavingMaterial = CreateMaterial(saveTextureName, "UnlitGeneric", {
	["$basetexture"] = saveTextureName,
})

local function renderMapView(x, y)
	local pos = LocalPlayer():GetPos() + Vector(x or 0, y or 0, ZOFFSET)

	render.SetRenderTarget(Star_Trek.Util.MapTexture)
		render.RenderView({
			origin = pos,
			angles = Vector(0, 0, -1):AngleEx(Vector(1, 0, 0)),
			x = 0,
			y = 0,
			w = RESOLUTION * SCALE,
			h = RESOLUTION * SCALE,
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
			znear = ZOFFSET - ZSLIVER,
			zfar = ZOFFSET + ZSLIVER,
			bloomtone = false,
		})
	render.PopRenderTarget()

	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(Star_Trek.Util.MapMaterial)
	surface.DrawTexturedRectUV(0, 0, 512 , 512, 0, 0, 1, 1)
end

local function drawSave()
	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(Star_Trek.Util.SavingMaterial)
	surface.DrawTexturedRectUV(0, 0, 512 , 512, 0, 0, 1, 1)
end

lastCalc = CurTime()
local function renderSaveFile()
	if lastCalc + 0.2 < CurTime() then
		lastCalc = CurTime()
	else
		drawSave()
		return
	end

	if Star_Trek.Util.SavingY == SCALE then
		Star_Trek.Util.Saving = false
		return
	end

	local u1 = Star_Trek.Util.SavingX / SCALE
	local u2 = u1 + 1 / SCALE
	local v1 = Star_Trek.Util.SavingY / SCALE
	local v2 = v1 + 1 / SCALE

	local oldW, oldH = ScrW(), ScrH()
	render.SetViewPort(0, 0, RESOLUTION, RESOLUTION)
	cam.Start2D()
		render.SetRenderTarget(Star_Trek.Util.SavingTexture)
			render.Clear(0,0,0,0, true, true)

			surface.SetDrawColor(255,255,255)
			surface.SetMaterial(Star_Trek.Util.MapMaterial)
			surface.DrawTexturedRectUV(0, 0, RESOLUTION , RESOLUTION, u1, v1, u2, v2)

			local data = render.Capture({
				format = "png",
				x = 0,
				y = 0,
				w = RESOLUTION,
				h = RESOLUTION,
				alpha = false,
			})

			file.Write("LCARS_" .. RESOLUTION .. "_" .. Star_Trek.Util.SavingX .. "_" .. Star_Trek.Util.SavingY .. ".png", data)
		render.PopRenderTarget()
	cam.End2D()
	render.SetViewPort(0, 0, oldW, oldH)

	if Star_Trek.Util.SavingX == SCALE - 1 then
		Star_Trek.Util.SavingX = 0
		Star_Trek.Util.SavingY = Star_Trek.Util.SavingY + 1
	else
		Star_Trek.Util.SavingX = Star_Trek.Util.SavingX + 1
	end

	drawSave()
end

concommand.Add("lcars_saveRT", function()
	Star_Trek.Util.Saving = true
	Star_Trek.Util.SavingX = 0
	Star_Trek.Util.SavingY = 0
end)

hook.Add("HUDPaint", "Test", function()
	if Star_Trek.Util.Saving then
		renderSaveFile()
	else
		renderMapView()
	end
end)
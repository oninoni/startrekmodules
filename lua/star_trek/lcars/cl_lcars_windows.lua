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
--       LCARS Windows | Client      --
---------------------------------------

------------------------
--       Opening      --
------------------------

-- Loads and converts the data of a single window into the format used by the render system.
-- 
-- @param Number id
-- @param Table windowData
-- @param Vector iPos
-- @param Angle iAng
-- @return Boolean success
-- @return? Table window
function Star_Trek.LCARS:LoadWindowData(id, windowData, pos, ang)
	local window = {
		WType = windowData.WType,
		Id = id,

		WPos = windowData.WPos,
		WAng = windowData.WAng,

		WVis = false,

		WScale = windowData.WScale,
		WWidth = windowData.WWidth,
		WD2 = windowData.WWidth / 2,
		WHeight = windowData.WHeight,
		HD2 = windowData.WHeight / 2,
	}

	local rtName = "LCARS_W_" .. window.Id .. "_" .. window.WWidth .. "_" .. window.WHeight
	window.RT = GetRenderTargetEx(rtName, window.WWidth, window.WHeight,
	RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(1, 256), 0, IMAGE_FORMAT_BGRA8888)

	window.RTMaterial = CreateMaterial(rtName, "UnlitGeneric", {
		["$basetexture"] = window.RT:GetName(),
		["$translucent"] = 1,
		["$vertexalpha"] = 1
	})

	window.WPosG, window.WAngG = LocalToWorld(window.WPos, window.WAng, pos, ang)

	local windowFunctions = self.Windows[windowData.WType]
	if not istable(windowFunctions) then
		return false, "Invalid Window Type"
	end
	setmetatable(window, {__index = windowFunctions})

	hook.Run("Star_Trek.LCARS.PreWindowCreate", window, windowData)

	local success = window:OnCreate(windowData)
	if not success then
		return false, "Window Creation Failed"
	end

	return true, window
end

------------------------
--       Drawing      --
------------------------

function Star_Trek.LCARS:RTDrawWindow(window, animPos)
	if not window.WVis then
		return
	end

	local width = window.WWidth
	local height = window.WHeight
	local pos = Star_Trek.LCARS:Get3D2DMousePos(window)

	if pos[1] > 0 and pos[1] < width
	and pos[2] > 0 and pos[2] < height then
		window.MouseActive = true
	else
		window.MouseActive = false
	end
	local override = hook.Run("Star_Trek.LCARS.MouseActive", window, pos)
	if override ~= nil then
		window.MouseActive = override
	end

	if window.MouseActive then
		window.LastPos = pos
	end
	local mousePos = window.LastPos

	render.PushRenderTarget(window.RT)
	cam.Start2D()
		render.Clear(0, 0, 0, 0, true, true)
		window:OnDraw(mousePos or Vector(-width / 2, -height / 2), animPos)
	cam.End2D()
	render.PopRenderTarget()
end

-- Draw the given window.
--
-- @param Table window
-- @param Number animPos
-- @param? Boolean drawCursor
function Star_Trek.LCARS:DrawWindow(window, animPos, drawCursor)
	if not window.WVis then
		return
	end

	local width = window.WWidth
	local height = window.WHeight

	local wPos, wAng, wScale = hook.Run("Star_Trek.LCARS.OverrideWindowPosAngScale", window)
	if not (wPos and wAng and wScale) then
		wPos, wAng, wScale = window.WPosG, window.WAngG, window.WScale
	end

	cam.Start3D2D(wPos, wAng, 1 / wScale)
		surface.SetMaterial(window.RTMaterial)
		surface.DrawTexturedRectUV(-width / 2, -height / 2, width, height, 0, 0, 1, 1)

		if drawCursor and window.MouseActive then
			local mousePos = window.LastPos

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Material("sprites/arrow"))
			surface.DrawTexturedRect(mousePos[1] - width / 2 - 15, mousePos[2] - height / 2 - 15, 30, 30)
		end
	cam.End3D2D()

	if isfunction(window.OnDraw3D) then
		window:OnDraw3D(wPos, wAng, animPos)
	end
end
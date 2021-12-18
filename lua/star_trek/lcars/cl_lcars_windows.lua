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
--    Copyright © 2021 Jan Ziegler   --
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
		WType = windowData.WindowType,
		Id = id,

		WPos = windowData.WindowPos,
		WAng = windowData.WindowAngles,

		WVis = false,

		WScale = windowData.WindowScale,
		WWidth = windowData.WindowWidth,
		WD2 = windowData.WindowWidth / 2,
		WHeight = windowData.WindowHeight,
		HD2 = windowData.WindowHeight / 2,
	}

	window.WPosG, window.WAngG = LocalToWorld(window.WPos, window.WAng, pos, ang)

	local windowFunctions = self.Windows[windowData.WindowType]
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
	local pos = Star_Trek.LCARS:Get3D2DMousePos(window)
	if pos[1] > -width * 0.6 and pos[1] < width * 0.6
	and pos[2] > -height * 0.6 and pos[2] < height * 0.6 then
		window.LastPos = pos
		window.MouseActive = true
	else
		window.MouseActive = false
	end

	local wPos, wAng, wScale = hook.Run("Star_Trek.LCARS.OverrideWindowPosAngScale", window)
	if not (wPos and wAng and wScale) then
		wPos, wAng, wScale = window.WPosG, window.WAngG, window.WScale
	end

	cam.Start3D2D(wPos, wAng, 1 / wScale)
		local mousePos = window.LastPos

		window:OnDraw(mousePos or Vector(-width / 2, -height / 2), animPos)

		if drawCursor and window.MouseActive then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Material("sprites/arrow"))
			surface.DrawTexturedRect(mousePos[1] - 15, mousePos[2] - 15, 30, 30)
		end
	cam.End3D2D()
end
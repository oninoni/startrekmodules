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
--           LCARS | Client          --
---------------------------------------

-- Marks the given interface, to be closed
--
-- @param Number id
function Star_Trek.LCARS:CloseInterface(id)
	if self.ActiveInterfaces[id] then
		self.ActiveInterfaces[id].Closing = true
	end
end

-- Receive the network message, to close an interface.
net.Receive("Star_Trek.LCARS.Close", function()
	local id = net.ReadInt(32)

	Star_Trek.LCARS:CloseInterface(id)
end)

-- Loads and converts the data of a single window into the format used by the render system.
-- 
-- @param Number id
-- @param Table windowData
-- @param Vector iPos
-- @param Angle iAng
-- @return window
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
		return false -- TODO: Add Errors
	end
	setmetatable(window, {__index = windowFunctions})

	local success = window:OnCreate(windowData)
	if not success then
		return false -- TODO: Add Errors
	end

	return window
end

-- Open a given interface and loads the data for all windows.
--
-- @param Number id
-- @param Table interfaceData
function Star_Trek.LCARS:OpenMenu(id, interfaceData)
	local interface = {
		Ent = interfaceData.Ent,
		IPos = interfaceData.InterfacePos,
		IAng = interfaceData.InterfaceAngle,

		IVis = false,

		AnimPos = 0,
		Closing = false,

		Windows = {},
	}

	local pos, ang = Star_Trek.LCARS:GetInterfacePosAngle(interface.Ent, interface.IPos, interface.IAng)

	for i, windowData in pairs(interfaceData.Windows) do
		local window = Star_Trek.LCARS:LoadWindowData(id .. "_" .. i, windowData, pos, ang)
		if istable(window) then
			interface.Windows[i] = window
			window.Interface = interface
		end
	end

	self.ActiveInterfaces[id] = interface
end

-- Receive the network message, to open an interface.
net.Receive("Star_Trek.LCARS.Open", function()
	local id = net.ReadInt(32)
	local interfaceData = net.ReadTable()

	Star_Trek.LCARS:OpenMenu(id, interfaceData)
end)

-- Returns the position of the mouse in the 2d plane of the window.
--
-- @param Table window
-- @param Vector eyePos
-- @param Angle eyeAng
-- @return Vector2D mousePos
function Star_Trek.LCARS:Get3D2DMousePos(window)
	local x, y = input.GetCursorPos()
	local rayDir = gui.ScreenToVector(x, y)

	local pos = util.IntersectRayWithPlane(self.EyePos, rayDir, window.WPosG, window.WAngG:Up())
	pos = WorldToLocal(pos or Vector(), Angle(), window.WPosG, window.WAngG)

	return Vector(pos.x * window.WScale, pos.y * -window.WScale, 0)
end

-- Main Think Hook for all LCARS Screens
local lastThink = CurTime()
hook.Add("Think", "Star_Trek.LCARS.Think", function()
	local curTime = CurTime()
	local diff = curTime - lastThink

	local ply = LocalPlayer()
	local eyePos = ply:EyePos()

	local removeInterfaces = {}
	for id, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
		interface.IVis = false

		local pos, ang = Star_Trek.LCARS:GetInterfacePosAngle(interface.Ent, interface.IPos, interface.IAng)

		for _, window in pairs(interface.Windows) do
			window.WPosG, window.WAngG = LocalToWorld(window.WPos, window.WAng, pos, ang)

			local cross = (window.WPosG - eyePos):Dot(window.WAngG:Up())

			if cross > 0 then
				window.WVis = false
			else
				window.WVis = true
				interface.IVis = true
			end
		end

		if interface.Closing then
			interface.AnimPos = math.max(0, interface.AnimPos - diff * 2)

			if interface.AnimPos == 0 then
				table.insert(removeInterfaces, id)
			end
		else
			interface.AnimPos = math.min(1, interface.AnimPos + diff * 2)
		end
	end

	for _, id in pairs(removeInterfaces) do
		Star_Trek.LCARS.ActiveInterfaces[id] = nil
	end

	lastThink = curTime
end)

-- Receive the network message, to update an interface.
net.Receive("Star_Trek.LCARS.Update", function()
	local id = net.ReadInt(32)

	local interface = Star_Trek.LCARS.ActiveInterfaces[id]
	if not istable(interface) then
		return
	end

	local windowId = net.ReadInt(32)
	local currentWindow = interface.Windows[windowId]

	local windowData = net.ReadTable()
	if currentWindow.WType ~= windowData.WindowType then
		local pos, ang = Star_Trek.LCARS:GetInterfacePosAngle(interface.Ent, interface.IPos, interface.IAng)

		local window = Star_Trek.LCARS:LoadWindowData(id .. "_" .. windowId, windowData, pos, ang)
		if istable(window) then
			interface.Windows[windowId] = window
			window.Interface = interface
		end
	else
		local success = currentWindow:OnCreate(windowData)
		if not success then
			print("Update Error")
		end
	end
end)

-- Recording interact presses and checking interaction with panel
hook.Add("KeyPress", "Star_Trek.LCARS.KeyPress", function(ply, key)
	if not (game.SinglePlayer() or IsFirstTimePredicted()) then return end

	if key ~= IN_USE and key ~= IN_ATTACK and key ~= IN_ATTACK2 then return end

	for id, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
		if not interface.IVis then
			continue
		end

		if interface.Closing and interface.AnimPos ~= 1 then
			continue
		end

		for i, window in pairs(interface.Windows) do
			if not window.WVis then
				continue
			end

			local width = window.WWidth
			local height = window.WHeight
			local pos = Star_Trek.LCARS:Get3D2DMousePos(window)
			if pos.x > -width / 2 and pos.x < width / 2
			and pos.y > -height / 2 and pos.y < height / 2 then
				local buttonId = window:OnPress(pos, interface.AnimPos)
				if buttonId then
					net.Start("Star_Trek.LCARS.Pressed")
						net.WriteInt(id, 32)
						net.WriteInt(i, 32)
						net.WriteInt(buttonId, 32)
					net.SendToServer()
				end
			end
		end
	end
end)

function Star_Trek.LCARS:DrawWindow(wPos, wAng, window, animPos)
	if not window.WVis then
		return
	end

	local width = window.WWidth
	local height = window.WHeight
	local pos = Star_Trek.LCARS:Get3D2DMousePos(window)
	if pos.x > -width * 0.6 and pos.x < width * 0.6
	and pos.y > -height * 0.6 and pos.y < height * 0.6 then
		window.LastPos = pos
	end

	cam.Start3D2D(wPos, wAng, 1 / window.WScale)
		window:OnDraw(window.LastPos or Vector(-width / 2, -height / 2), animPos)
	cam.End3D2D()
end

hook.Add("PreDrawTranslucentRenderables", "Star_Trek.LCARS.PreDraw", function(isDrawingDepth, isDrawingSkybox)
	if isDrawingSkybox then return end
	if (wp.drawing) then return end

	Star_Trek.LCARS.EyePos = LocalPlayer():EyePos()
end)

-- Main Render Hook for all LCARS Screens
hook.Add("PostDrawTranslucentRenderables", "Star_Trek.LCARS.Draw", function(isDrawingDepth, isDrawingSkybox)
	if isDrawingSkybox then return end
	if (wp.drawing) then return end

	for _, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
		if not interface.IVis then
			continue
		end

		local animPos = interface.AnimPos

		render.SuppressEngineLighting(true)

		for _, window in pairs(interface.Windows) do
			Star_Trek.LCARS:DrawWindow(window.WPosG, window.WAngG, window, animPos)
		end

		surface.SetAlphaMultiplier(1)
		render.SuppressEngineLighting(false)
	end
end)
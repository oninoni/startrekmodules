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

net.Receive("Star_Trek.LCARS.Close", function()
	local id = net.ReadInt(32)

	Star_Trek.LCARS:CloseInterface(id)
end)

function Star_Trek.LCARS:LoadWindowData(id, windowData, IPos, IAng)
	local windowFunctions = self.Windows[windowData.WindowType]
	if not istable(windowFunctions) then
		return
	end

	local pos, ang = LocalToWorld(windowData.WindowPos, windowData.WindowAngles, IPos, IAng)

	local window = {
		WType = windowData.WindowType,
		Id = id,

		WPos = pos,
		WAng = ang,

		WVis = false,

		WVU = ang:Up(),
		WVR = ang:Right(),
		WVF = ang:Forward(),

		WScale = windowData.WindowScale,
		WWidth = windowData.WindowWidth,
		WHeight = windowData.WindowHeight,
	}

	return windowFunctions.OnCreate(window, windowData)
end

function Star_Trek.LCARS:OpenMenu(id, interfaceData)
	local interface = {
		IPos = interfaceData.InterfacePos,
		IAng = interfaceData.InterfaceAngle,

		IVU = interfaceData.InterfaceAngle:Up(),
		IVR = interfaceData.InterfaceAngle:Right(),
		IVF = interfaceData.InterfaceAngle:Forward(),

		IVis = false,

		AnimPos = 0,
		Closing = false,

		Windows = {},
	}

	for i, windowData in pairs(interfaceData.Windows) do
		local window = Star_Trek.LCARS:LoadWindowData(id .. "_" .. i, windowData, interface.IPos, interface.IAng)
		if istable(window) then
			interface.Windows[i] = window
		end
	end

	self.ActiveInterfaces[id] = interface
end

net.Receive("Star_Trek.LCARS.Open", function()
	local id = net.ReadInt(32)
	local interfaceData = net.ReadTable()

	Star_Trek.LCARS:OpenMenu(id, interfaceData)
end)

-- Returns the position of the mouse in the 2d plane of the window.
--
-- @param Table window
-- @param Vector eyePos
-- @param Vector eyeVector
-- @return Vector2D mousePos
function Star_Trek.LCARS:Get3D2DMousePos(window, eyePos, eyeVector)
	local pos = util.IntersectRayWithPlane(eyePos, eyeVector, window.WPos, window.WVU)
	pos = WorldToLocal(pos or Vector(), Angle(), window.WPos, window.WAng)

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

		for _, window in pairs(interface.Windows) do
			local trace = util.TraceLine({
				start = eyePos,
				nedpos = window.WPos,
				filter = ply
			})

			local cross = (window.WPos - eyePos):Dot(window.WAng:Up())

			if not trace.Hit or cross > 0 then
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

net.Receive("Star_Trek.LCARS.Update", function()
	local id = net.ReadInt(32)
	local windowId = net.ReadInt(32)
	local windowData = net.ReadTable()

	local interface = Star_Trek.LCARS.ActiveInterfaces[id]
	if not istable(interface) then
		return
	end

	local oldVisible = interface.Windows[windowId].WVis

	local window = Star_Trek.LCARS:LoadWindowData(id .. "_" .. windowId, windowData, interface.IPos, interface.IAng)
	if istable(window) then
		interface.Windows[windowId] = window
		-- table.Merge(interface.Windows[windowId], window)
	end

	interface.Windows[windowId].WVis = oldVisible
end)

-- Recording interact presses and checking interaction with panel
hook.Add("KeyPress", "Star_Trek.LCARS.KeyPress", function(ply, key)
	if not (game.SinglePlayer() or IsFirstTimePredicted()) then return end

	if key ~= IN_USE and key ~= IN_ATTACK then return end

	local eyePos = LocalPlayer():EyePos()
	local eyeDir = EyeVector()

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
			local pos = Star_Trek.LCARS:Get3D2DMousePos(window, eyePos, eyeDir)
			if pos.x > -width / 2 and pos.x < width / 2
			and pos.y > -height / 2 and pos.y < height / 2 then
				local windowFunctions = Star_Trek.LCARS.Windows[window.WType]
				if not istable(windowFunctions) then
					continue
				end

				local buttonId = windowFunctions.OnPress(window, pos, interface.AnimPos)
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

-- Main Render Hook for all LCARS Screens
hook.Add("PostDrawOpaqueRenderables", "Star_Trek.LCARS.Draw", function(isDrawingDepth, isDrawSkyBox)
	if isDrawSkyBox then return end
	if ( wp.drawing ) then return end

	local eyePos = LocalPlayer():EyePos()
	local eyeDir = EyeVector()

	for _, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
		if not interface.IVis then
			continue
		end

		render.SuppressEngineLighting(true)

		for _, window in pairs(interface.Windows) do
			if not window.WVis then
				continue
			end

			local width = window.WWidth
			local height = window.WHeight
			local pos = Star_Trek.LCARS:Get3D2DMousePos(window, eyePos, eyeDir)
			if pos.x > -width / 2 and pos.x < width / 2
			and pos.y > -height / 2 and pos.y < height / 2 then
				window.LastPos = pos
			end

			local windowFunctions = Star_Trek.LCARS.Windows[window.WType]
			if not istable(windowFunctions) then
				continue
			end

			cam.Start3D2D(window.WPos, window.WAng, 1 / window.WScale)
				windowFunctions.OnDraw(window, window.LastPos or Vector(-width / 2, -height / 2), interface.AnimPos)
			cam.End3D2D()
		end

		render.SuppressEngineLighting(false)
	end
end)


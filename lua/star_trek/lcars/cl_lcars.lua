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
	local interface = self.ActiveInterfaces[id]
	if interface then
		interface.Closing = true

		hook.Run("Star_Trek.LCARS.CloseInterface", id, interface)
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

	local success = window:OnCreate(windowData)
	if not success then
		return false, "Window Creation Failed"
	end

	return true, window
end

-- Open a given interface and loads the data for all windows.
--
-- @param Number id
-- @param Table interfaceData
-- @return Boolean success
-- @return? Table interface
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
		local success, window = Star_Trek.LCARS:LoadWindowData(id .. "_" .. i, windowData, pos, ang)
		if not success then
			return false, window
		end

		if istable(window) then
			interface.Windows[i] = window
			window.Interface = interface
		end
	end

	if IsValid(interfaceData.Ent) then
		interfaceData.Ent.InterfaceId = id
	end

	hook.Run("Star_Trek.LCARS.OpenMenu", id, interfaceData, interface)

	self.ActiveInterfaces[id] = interface

	return true, interface
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
	pos = Vector(pos[1] * window.WScale, pos[2] * -window.WScale, 0)

	local overriddenPos = hook.Run("Star_Trek.LCARS.Get3D2DMousePos", window, pos)
	if isvector(overriddenPos) then
		return overriddenPos
	end

	return pos
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

		local success, window = Star_Trek.LCARS:LoadWindowData(id .. "_" .. windowId, windowData, pos, ang)
		if not success then
			print(window)
		end

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

function Star_Trek.LCARS:PlayerButtonDown(ply, button)
	if button ~= KEY_E and button ~= MOUSE_LEFT and button ~= MOUSE_RIGHT then return end

	for id, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
		if not interface.IVis then
			continue
		end

		if interface.Closing and interface.AnimPos ~= 1 then
			continue
		end

		-- Splitting Inputs, if a weapon and a world Interface is both used.
		local weapon = ply:GetActiveWeapon()
		if weapon.IsLCARS then
			if button == KEY_E
			and interface.Ent == weapon then
				continue
			end

			if (button == MOUSE_LEFT or button == MOUSE_RIGHT)
			and interface.Ent ~= weapon then
				continue
			end
		end

		for i, window in pairs(interface.Windows) do
			if not window.WVis then
				continue
			end

			local width = window.WWidth
			local height = window.WHeight
			local pos = Star_Trek.LCARS:Get3D2DMousePos(window)
			if pos[1] > -width / 2 and pos[1] < width / 2
			and pos[2] > -height / 2 and pos[2] < height / 2 then
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
end

-- MultiPlayer PlayerButtonDown Hook.
hook.Add("PlayerButtonDown", "Star_Trek.LCARS.PlayerButtonDown", function(ply, button)
	if not (game.SinglePlayer() or IsFirstTimePredicted()) then return end

	Star_Trek.LCARS:PlayerButtonDown(ply, button)
end)

-- SinglePlayer PlayerButtonDown Net.
net.Receive("Star_Trek.LCARS.PlayerButtonDown", function()
	local button = net.ReadInt(32)
	Star_Trek.LCARS:PlayerButtonDown(LocalPlayer(), button)
end)

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
	end

	cam.Start3D2D(window.WPosG, window.WAngG, 1 / window.WScale)
		window:OnDraw(window.LastPos or Vector(-width / 2, -height / 2), animPos)

		if drawCursor then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Material("sprites/arrow"))
			surface.DrawTexturedRect(pos[1] - 15, pos[2] - 15, 30, 30)
		end
	cam.End3D2D()
end

hook.Add("PreDrawTranslucentRenderables", "Star_Trek.LCARS.PreDraw", function(isDrawingDepth, isDrawingSkybox)
	if isDrawingSkybox then return end
	if not wp then return end
	if (wp.drawing) then return end

	Star_Trek.LCARS.EyePos = LocalPlayer():EyePos()
end)

-- Main Render Hook for all LCARS Screens
hook.Add("PostDrawTranslucentRenderables", "Star_Trek.LCARS.Draw", function(isDrawingDepth, isDrawingSkybox)
	if isDrawingSkybox then return end
	if not wp then return end
	if (wp.drawing) then return end

	for _, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
		if not interface.IVis then
			continue
		end

		local ent = interface.Ent
		if IsValid(ent) and ent:IsWeapon() and IsValid(ent:GetOwner()) and ent:GetOwner() == LocalPlayer() then
			continue
		end

		render.SuppressEngineLighting(true)

		for _, window in pairs(interface.Windows) do
			Star_Trek.LCARS:DrawWindow(window, interface.AnimPos)
		end

		surface.SetAlphaMultiplier(1)
		render.SuppressEngineLighting(false)
	end
end)
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
--     LCARS Interfaces | Client     --
---------------------------------------

------------------------
--       Opening      --
------------------------

-- Open a given interface and loads the data for all windows.
--
-- @param Number id
-- @param Table interfaceData
-- @return Boolean success
-- @return? Table interface
function Star_Trek.LCARS:OpenInterface(id, interfaceData)
	local ent = interfaceData.Ent

	local interface = {
		Ent = ent,
		IPos = interfaceData.InterfacePos,
		IAng = interfaceData.InterfaceAngle,

		IVis = false,

		AnimPos = 0,
		Closing = false,

		Windows = {},
	}

	local pos, ang = Star_Trek.LCARS:GetInterfacePosAngle(ent, interface.IPos, interface.IAng)

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

	self.ActiveInterfaces[id] = interface
	if IsValid(ent) then
		ent.InterfaceId = id
	end

	return true, interface
end

-- Receive the network message, to open an interface.
net.Receive("Star_Trek.LCARS.Open", function()
	local id = net.ReadInt(32)
	local interfaceData = net.ReadTable()

	Star_Trek.LCARS:OpenInterface(id, interfaceData)
end)

------------------------
--      Closing       --
------------------------

-- Marks the given interface, to be closed.
--
-- @param Number id
function Star_Trek.LCARS:CloseInterface(id)
	local interface = self.ActiveInterfaces[id]
	if interface then
		interface.Closing = true
	end
end

-- Receive the network message, to close an interface.
net.Receive("Star_Trek.LCARS.Close", function()
	local id = net.ReadInt(32)

	Star_Trek.LCARS:CloseInterface(id)
end)

------------------------
--      Updating      --
------------------------

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

-- Handle a button press.
--
-- @param Player ply
-- @param Number button
function Star_Trek.LCARS:PlayerButtonDown(ply, button)
	if not ((button == KEY_E and not ply.DisableEButton) or button == MOUSE_LEFT or button == MOUSE_RIGHT) then return end

	for id, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
		if not interface.IVis then
			continue
		end

		if hook.Run("Star_Trek.LCARS.PreventRender", interface, true) then
			continue
		end

		if hook.Run("Star_Trek.LCARS.PreventButton", interface) then
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

-- Save EyePos on Regular Intervals.
-- TODO: Do you need it?
hook.Add("PreDrawTranslucentRenderables", "Star_Trek.LCARS.PreDraw", function(isDrawingDepth, isDrawingSkybox)
	if isDrawingSkybox then return end
	if wp and wp.drawing then return end

	Star_Trek.LCARS.EyePos = LocalPlayer():EyePos()
end)

-- Main Think Hook for all LCARS Screens
local lastThink = CurTime()
hook.Add("Think", "Star_Trek.LCARS.Think", function()
	local curTime = CurTime()
	local diff = curTime - lastThink

	local ply = LocalPlayer()
	local eyePos = ply:EyePos()

	local removeInterfaces = {}
	for id, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
		if hook.Run("Star_Trek.LCARS.PreventRender", interface, true) then
			continue
		end

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

------------------------
--       Drawing      --
------------------------

-- Main Render Hook for all LCARS Screens
hook.Add("PostDrawTranslucentRenderables", "Star_Trek.LCARS.Draw", function(isDrawingDepth, isDrawingSkybox)
	if isDrawingSkybox then return end
	if wp and wp.drawing then return end

	for _, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
		if not interface.IVis then
			continue
		end

		if hook.Run("Star_Trek.LCARS.PreventRender", interface) then
			continue
		end

		render.OverrideBlend(true, BLEND_SRC_ALPHA, BLEND_ONE, BLENDFUNC_ADD, BLEND_SRC_ALPHA, BLEND_ONE, BLENDFUNC_ADD)

		for _, window in pairs(interface.Windows) do
			Star_Trek.LCARS:DrawWindow(window, interface.AnimPos)
		end

		render.OverrideBlend(false)

		surface.SetAlphaMultiplier(1)
	end
end)
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
--     LCARS Interfaces | Client     --
---------------------------------------

------------------------
--       Opening      --
------------------------

Star_Trek.LCARS.WaitingInterfaces = Star_Trek.LCARS.WaitingInterfaces or {}

-- Open a given interface and loads the data for all windows.
--
-- @param Number id
-- @param Table interfaceData
-- @return Boolean success
-- @return? Table interface
function Star_Trek.LCARS:OpenInterface(id, interfaceData)
	local ent = ents.GetByIndex(id)

	-- If the entity is not valid, wait for it to be created.
	if not IsValid(ent) then
		self.WaitingInterfaces[id] = interfaceData

		return false, "Waiting for Entity"
	end

	local interface = {
		Ent = ent,
		IPos = interfaceData.InterfacePos,
		IAng = interfaceData.InterfaceAngle,

		IVis = false,
		Solid = interfaceData.Solid,

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
	local interfaceData = Star_Trek.Util:ReadNetTable()

	Star_Trek.LCARS:OpenInterface(id, interfaceData)
end)

-- If an entity is created, check if it has an interface, that was waiting for it.
hook.Add("NetworkEntityCreated", "Star_Trek.LCARS.CreateWaitingInterface", function(ent)
	local id = ent:EntIndex()

	local interfaceData = Star_Trek.LCARS.WaitingInterfaces[id]
	if not istable(interfaceData) then return end

	Star_Trek.LCARS:OpenInterface(id, interfaceData)

	Star_Trek.LCARS.WaitingInterfaces[id] = nil
end)

-- Request the interface data from the server.
hook.Add("InitPostEntity", "Star_Trek.LCARS.RequestSync", function()
	if game.SinglePlayer() then return end

	net.Start("Star_Trek.LCARS.Sync")
	net.SendToServer()
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

		for _, window in pairs(interface.Windows) do
			window:OnClose()
		end
	end
end

-- Receive the network message, to close an interface.
net.Receive("Star_Trek.LCARS.Close", function()
	local id = net.ReadInt(32)
	print("Close", id)

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
	local oldVis = currentWindow.WVis

	local windowData = Star_Trek.Util:ReadNetTable()
	if currentWindow.WType ~= windowData.WType then
		local pos, ang = Star_Trek.LCARS:GetInterfacePosAngle(interface.Ent, interface.IPos, interface.IAng)

		local success, window = Star_Trek.LCARS:LoadWindowData(id .. "_" .. windowId, windowData, pos, ang)
		if not success then
			print(window)
		end

		if istable(window) then
			interface.Windows[windowId] = window

			window.Interface = interface
			window.WVis = oldVis
		end
	else
		hook.Run("Star_Trek.LCARS.PreWindowCreate", currentWindow, windowData)

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

	if not ply:Alive() then return end

	for id, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
		if not interface.IVis then
			continue
		end

		if not IsValid(interface.Ent) then
			interface.Ent = ents.GetByIndex(id)
			if not IsValid(interface.Ent) then
				continue
			end
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

			if not window.MouseActive then
				continue
			end

			local width = window.WWidth
			local height = window.WHeight
			local pos = Star_Trek.LCARS:Get3D2DMousePos(window)
			if pos[1] > 0 and pos[1] < width
			and pos[2] > 0 and pos[2] < height then
				local worldPos = Vector(pos[1] / window.WScale, pos[2] / -window.WScale, 0)
				worldPos = LocalToWorld(worldPos or Vector(), Angle(), window.WPosG, window.WAngG)

				local eyePos = ply:EyePos()
				local fullDistance = worldPos:Distance(eyePos)
				if fullDistance > 80 then
					continue
				end

				local forwardTrace = util.TraceLine({
					start = eyePos,
					endpos = worldPos,
					filter = {
						ply,
						interface.Ent
					},
				})
				local backwardsTrace = util.TraceLine({
					start = worldPos,
					endpos = eyePos,
					filter = {
						ply,
						interface.Ent
					},
				})

				-- debugoverlay.Line(eyePos, forwardTrace.HitPos, 10, Color(255, 0, 0), true)
				-- debugoverlay.Line(worldPos, backwardsTrace.HitPos, 10, Color(255, 0, 0), true)

				local forwardsDistance = eyePos:Distance(forwardTrace.HitPos)
				local backwardsDistance = worldPos:Distance(backwardsTrace.HitPos)

				if forwardTrace.HitWorld and backwardsTrace.HitWorld then
					if fullDistance - 10 > forwardsDistance then
						continue
					end
				else
					if fullDistance > forwardsDistance + backwardsDistance + 1 then
						continue
					end
				end

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
		interface.IVis = false

		if not IsValid(interface.Ent) then
			interface.Ent = ents.GetByIndex(id)
			if not IsValid(interface.Ent) then
				continue
			end
		end

		if hook.Run("Star_Trek.LCARS.PreventRender", interface, true) then
			continue
		end

		local pos, ang = Star_Trek.LCARS:GetInterfacePosAngle(interface.Ent, interface.IPos, interface.IAng)

		for _, window in pairs(interface.Windows) do
			window:OnThink()

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

		-- Only Check! Dont fix! (For Performance Reasons!)
		if not IsValid(interface.Ent) then
			continue
		end

		if hook.Run("Star_Trek.LCARS.PreventRender", interface) then
			continue
		end

		surface.SetAlphaMultiplier(1)
		for _, window in pairs(interface.Windows) do
			render.OverrideBlend(false)

			Star_Trek.LCARS:RTDrawWindow(window, interface.AnimPos)

			if not interface.Solid and not window.Solid then
				render.OverrideBlend(true, BLEND_SRC_ALPHA, BLEND_ONE, BLENDFUNC_ADD, BLEND_SRC_ALPHA, BLEND_ONE, BLENDFUNC_ADD)
			end

			Star_Trek.LCARS:DrawWindow(window, interface.AnimPos)
		end

		render.OverrideBlend(false)
		surface.SetAlphaMultiplier(1)
		render.OverrideDepthEnable(false)
	end
end)
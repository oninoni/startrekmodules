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
--     LCARS Interfaces | Server     --
---------------------------------------

------------------------
--       Opening      --
------------------------

util.AddNetworkString("Star_Trek.LCARS.Open")

-- Applies Offset and Values to all Windows.
--
-- @param Table interfaceData
-- @param interfaceData
function Star_Trek.LCARS:ApplyWindows(interfaceData)
	for windowId, windowData in ipairs(interfaceData.Windows or {}) do
		self:ApplyWindow(interfaceData, windowId, windowData)
	end
end

-- Opens an interface of the given name.
--
-- @param Player ply
-- @param Entity triggerEntity
-- @param String interfaceName
-- @param vararg ...
-- @return Boolean Success
-- @return? String error
function Star_Trek.LCARS:OpenInterface(ply, triggerEntity, interfaceName, ...)
	local success, ent = self:GetInterfaceEntity(ply, triggerEntity)
	if not success then
		return false, ent
	end

	if istable(self.ActiveInterfaces[ent]) then
		return true
	end

	local interfacePos, interfaceAngle = self:GetInterfacePosAngle(ent)
	if not (isvector(interfacePos) and isangle(interfaceAngle)) then
		return false, "Invalid Interface Pos/Angle!"
	end

	local interfaceData = {
		Ent 			= ent,
		InterfacePos	= interfacePos,
		InterfaceAngle	= interfaceAngle,
	}

	local interfaceFunctions = self.Interfaces[interfaceName]
	if not istable(interfaceFunctions) then
		return false, "Invalid Interface Name"
	end
	setmetatable(interfaceData, {__index = interfaceFunctions})

	local success2, windows, offsetPos, offsetAng = interfaceData:Open(ent, ...)
	if not success2 then
		return false, windows
	end

	if not istable(windows) or table.Count(windows) < 1 then
		return false, "Invalid Interface Windows"
	end

	interfaceData.Windows = windows
	interfaceData.OffsetPos = offsetPos
	interfaceData.OffsetAng = offsetAng
	Star_Trek.LCARS:ApplyWindows(interfaceData)

	local clientInterfaceData = Star_Trek.LCARS:GetClientInterfaceData(interfaceData)

	net.Start("Star_Trek.LCARS.Open")
		net.WriteInt(ent:EntIndex(), 32)
		net.WriteTable(clientInterfaceData)
	net.Broadcast()

	self.ActiveInterfaces[ent] = interfaceData
	ent.Interface = interfaceData

	hook.Run("Star_Trek.LCARS.PostOpenInterface", ent)

	return true
end

------------------------
--      Closing       --
------------------------

util.AddNetworkString("Star_Trek.LCARS.Close")

-- Closes the given interface.
-- 
-- @param Entity ent
-- @param? Function callback
-- @return Boolean Success
-- @return? String error
function Star_Trek.LCARS:CloseInterface(ent, callback)
	if not IsValid(ent) then
		return false, "Invalid Interface Entity!"
	end

	if timer.Exists("Star_Trek.LCARS." .. ent:EntIndex()) then
		return true
	end

	local interfaceData = Star_Trek.LCARS.ActiveInterfaces[ent]
	if interfaceData then
		net.Start("Star_Trek.LCARS.Close")
			net.WriteInt(ent:EntIndex(), 32)
		net.Broadcast()

		interfaceData.Closing = true
		ent.LastData = interfaceData:GetData()
		if istable(ent.LastDat) and table.Count(ent.LastData) == 0 then
			ent.LastData = false
		end

		timer.Create("Star_Trek.LCARS." .. ent:EntIndex(), 0.5, 1, function()
			Star_Trek.LCARS.ActiveInterfaces[ent] = nil
			ent.Interface = nil

			timer.Remove("Star_Trek.LCARS." .. ent:EntIndex())

			if isfunction(callback) then
				callback()
			end
		end)

		hook.Run("Star_Trek.LCARS.PostCloseInterface", ent)

		return true
	end

	if isfunction(callback) then
		callback()
	end

	return false
end

-- Capture closeLcars Input
hook.Add("AcceptInput", "Star_Trek.LCARS.Close", function(ent, input, activator, caller, value)
	if input ~= "CloseLcars" then return end

	if Star_Trek.LCARS.ActiveInterfaces[ent] then
		Star_Trek.LCARS:CloseInterface(ent)
	end
end)

-- Closing the panel when you are too far away.
-- This is also done clientside so we don't need to network.
hook.Add("Think", "Star_Trek.LCARS.ThinkClose", function()
	local removeInterfaces = {}
	for ent, interfaceData in pairs(Star_Trek.LCARS.ActiveInterfaces) do
		if not IsValid(ent) then
			table.insert(removeInterfaces, ent)
			continue
		end

		local keyValues = ent.LCARSKeyData
		if istable(keyValues) and keyValues["lcars_never_close"] then
			continue
		end

		local pos = ent:LocalToWorld(interfaceData.InterfacePos)
		local entities = ents.FindInSphere(pos, 128)
		local playersFound = false
		for _, target in pairs(entities or {}) do
			if target:IsPlayer() then
				playersFound = true
			end
		end

		if not playersFound then
			table.insert(removeInterfaces, ent)
		end
	end

	for _, ent in pairs(removeInterfaces) do
		Star_Trek.LCARS:CloseInterface(ent)
	end
end)

------------------------
--      Updating      --
------------------------

util.AddNetworkString("Star_Trek.LCARS.Pressed")

-- Receive the pressed event from the client when a user presses his panel.
net.Receive("Star_Trek.LCARS.Pressed", function(len, ply)
	local id = net.ReadInt(32)
	local windowId = net.ReadInt(32)
	local buttonId = net.ReadInt(32)

	local ent = ents.GetByIndex(id)
	if not IsValid(ent) then
		return
	end

	local interfaceData = Star_Trek.LCARS.ActiveInterfaces[ent]
	if not istable(interfaceData) then
		return
	end

	local windowData = interfaceData.Windows[windowId]
	if not istable(windowData) then
		return
	end

	local shouldUpdate = windowData:OnPress(interfaceData, ent, buttonId, windowData.Callback)
	if shouldUpdate then
		windowData:Update()
	end
end)

-- SinglePlayer PlayerButtonDown Hook.
if game.SinglePlayer() and SERVER then
	util.AddNetworkString("Star_Trek.LCARS.PlayerButtonDown")

	hook.Add("PlayerButtonDown", "Star_Trek.LCARS.PlayerButtonDown", function(ply, button)
		net.Start("Star_Trek.LCARS.PlayerButtonDown")
			net.WriteInt(button, 32)
		net.Send(ply)
	end)
end
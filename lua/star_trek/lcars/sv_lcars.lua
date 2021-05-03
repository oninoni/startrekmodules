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
--           LCARS | Server          --
---------------------------------------

---------------------------------------
--              Opening              --
---------------------------------------

util.AddNetworkString("Star_Trek.LCARS.Open")
util.AddNetworkString("Star_Trek.LCARS.Sync") -- TODO: Sync on Join Active Interfaces

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
		Ent = ent,
		InterfacePos    = interfacePos,
		InterfaceAngle  = interfaceAngle,
	}

	local interfaceFunctions = self.Interfaces[interfaceName]
	if not istable(interfaceFunctions) then
		return false, "Invalid Interface Name"
	end
	setmetatable(interfaceData, {__index = interfaceFunctions})

	local success2, windows = interfaceData:Open(ent, ...)
	if not success2 then
		return false, windows
	end

	if not istable(windows) or table.Count(windows) < 1 then
		return false, "Invalid Interface Windows"
	end

	interfaceData.Windows = windows
	for i, windowData in ipairs(interfaceData.Windows) do
		windowData.Id = i
		windowData.Interface = interfaceData
	end

	local clientInterfaceData = Star_Trek.LCARS:GetClientInterfaceData(interfaceData)

	net.Start("Star_Trek.LCARS.Open")
		net.WriteInt(ent:EntIndex(), 32)
		net.WriteTable(clientInterfaceData)
	net.Broadcast()

	self.ActiveInterfaces[ent] = interfaceData

	return true
end

---------------------------------------
--              Closing              --
---------------------------------------

util.AddNetworkString("Star_Trek.LCARS.Close")

-- Closes the given interface.
-- 
-- @param Entity ent
-- @return Boolean Success
-- @return? String error
function Star_Trek.LCARS:CloseInterface(ent)
	if not IsValid(ent) then
		return false, "Invalid Interface Entity!"
	end

	if timer.Exists("Star_Trek.LCARS." .. ent:EntIndex()) then
		return true
	end

	net.Start("Star_Trek.LCARS.Close")
		net.WriteInt(ent:EntIndex(), 32)
	net.Broadcast()

	local interfaceData = Star_Trek.LCARS.ActiveInterfaces[ent]
	if interfaceData then
		interfaceData.Closing = true
		ent.LastData = interfaceData:GetData()
		if istable(ent.LastDat) and table.Count(ent.LastData) == 0 then
			ent.LastData = false
		end

		timer.Create("Star_Trek.LCARS." .. ent:EntIndex(), 0.5, 1, function()
			Star_Trek.LCARS.ActiveInterfaces[ent] = nil
			timer.Remove("Star_Trek.LCARS." .. ent:EntIndex())
		end)

		return true
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

---------------------------------------
--              Updating             --
---------------------------------------

util.AddNetworkString("Star_Trek.LCARS.Update")
util.AddNetworkString("Star_Trek.LCARS.Pressed")

-- Updates the window of the given id.
--
-- @param Entity ent
-- @param Number windowId
-- @param? Table windowData
function Star_Trek.LCARS:UpdateWindow(ent, windowId, windowData)
	local interfaceData = self.ActiveInterfaces[ent]

	if istable(windowData) then
		interfaceData.Windows[windowId] = windowData
	end

	local clientWindowData = self:GetClientWindowData(interfaceData.Windows[windowId])

	net.Start("Star_Trek.LCARS.Update")
		net.WriteInt(ent:EntIndex(), 32)
		net.WriteInt(windowId, 32)
		net.WriteTable(clientWindowData)
	net.Broadcast()
end

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

---------------------------------------
--              Loading              --
---------------------------------------

-- Load a given interface.
--
-- @param String interfaceName
-- @return Boolean success
-- @return Table interface
function Star_Trek.LCARS:LoadInterface(interfaceName)
	if istable(self.Interfaces[interfaceName]) then
		return true, self.Interfaces[interfaceName]
	end

	INTERFACE = {}

	include("interfaces/" .. interfaceName .. "/init.lua")

	local interface = INTERFACE
	INTERFACE = nil

	if isstring(interface.BaseInterface) then
		local success, baseInterface = self:LoadInterface(interface.BaseInterface)
		if not success then
			return false, baseInterface
		end

		interface.Base = baseInterface
		setmetatable(interface, {__index = baseInterface})
	end

	self.Interfaces[interfaceName] = interface

	return true, self.Interfaces[interfaceName]
end

-- Load all interfaces.
function Star_Trek.LCARS:LoadInterfaces()
	self.Interfaces = {}

	local _, directories = file.Find("star_trek/lcars/interfaces/*", "LUA")

	for _, interfaceName in pairs(directories) do
		local success, interface = self:LoadInterface(interfaceName)
		if success then
			Star_Trek:Message("Loaded LCARS Interface Type \"" .. interfaceName .. "\"")
		else
			Star_Trek:Message(interface)
		end
	end
end
Star_Trek.LCARS:LoadInterfaces()
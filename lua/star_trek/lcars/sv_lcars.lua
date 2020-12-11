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

util.AddNetworkString("Star_Trek.LCARS.Close")
util.AddNetworkString("Star_Trek.LCARS.Open")
util.AddNetworkString("Star_Trek.LCARS.Sync")
util.AddNetworkString("Star_Trek.LCARS.Update")
util.AddNetworkString("Star_Trek.LCARS.Pressed")

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

	if Star_Trek.LCARS.ActiveInterfaces[ent] then
		Star_Trek.LCARS.ActiveInterfaces[ent].Closing = true

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


-- Retrieves the position and angle of the center of the created interface for that entity.
-- Uses either the origin or an "button" attachment point of the entity.
--
-- @param Entity ent
-- @return Vector interfacePos
-- @return Angle interfaceAngle
function Star_Trek.LCARS:GetInterfacePosAngle(ent)
	local interfacePos = ent:GetPos()
	local interfaceAngle = ent:GetUp():Angle()

	-- If "movedir" keyvalue is set, then override interfaceAngle
	local moveDir = ent:GetKeyValues()["movedir"]
	if isvector(moveDir) then
		interfaceAngle = moveDir:Angle()
	end

	-- If an "button" attachment exists on the model of the entity, then that is used instead.
	local attachmentID = ent:LookupAttachment("button")
	if isnumber(attachmentID) and attachmentID > 0 then
		local attachmentPoint = ent:GetAttachment(attachmentID)
		interfacePos = attachmentPoint.Pos
		interfaceAngle = attachmentPoint.Ang
	end

	local modelSetting = self.ModelSettings[ent:GetModel()]
	if istable(modelSetting) then
		interfacePos = interfacePos + interfaceAngle:Forward() * modelSetting.Offset
	end

	interfaceAngle:RotateAroundAxis(interfaceAngle:Right(), -90)
	interfaceAngle:RotateAroundAxis(interfaceAngle:Up(), 90)

	return interfacePos, interfaceAngle
end

-- Opens a given interface at the given console entity.
--
-- @param Entity ent
-- @param Table windows
-- @return Boolean Success
-- @return? String error
function Star_Trek.LCARS:OpenInterface(ent, windows)
	if not IsValid(ent) then
		return false, "Invalid Interface Entity!"
	end

	if istable(self.ActiveInterfaces[ent]) then
		return true
	end

	local interfacePos, interfaceAngle = self:GetInterfacePosAngle(ent)
	if not (isvector(interfacePos) and isangle(interfaceAngle)) then
		return false, "Invalid Interface Pos/Angle!"
	end

	if not istable(windows) then
		return false, "No Interface Windows given!"
	end

	local interfaceData = {
		InterfacePos    = interfacePos,
		InterfaceAngle  = interfaceAngle,

		Windows         = windows,
	}

	local interfaceDataClient = table.Copy(interfaceData)
	for _, windowData in pairs(interfaceDataClient.Windows) do
		windowData.Callback = nil
	end

	net.Start("Star_Trek.LCARS.Open")
		net.WriteInt(ent:EntIndex(), 32)
		net.WriteTable(interfaceDataClient)
	net.Broadcast()

	self.ActiveInterfaces[ent] = interfaceData

	return true
end

-- Retrieves the actual interface Entity from the entity that it is triggered from.
--
-- @param Player ply
-- @param Entity triggerEntity
-- @return Boolean Success
-- @return? String/Entity error/ent
function Star_Trek.LCARS:GetInterfaceEntity(ply, triggerEntity)
	if not IsValid(triggerEntity) then
		return false, "Invalid Interface Trigger Entity"
	end

	-- If no children, then use trigger Entity.
	local children = triggerEntity:GetChildren()
	if table.Count(children) == 0 then
		return true, triggerEntity
	end

	-- If triggered by non-player, then use trigger Entity.
	if not (IsValid(ply) and ply:IsPlayer()) then
		return true, triggerEntity
	end

	-- Check if Eye Trace Entity is a child.
	local ent = ply:GetEyeTrace().Entity
	if not IsValid(ent) or ent:IsWorld() then
		return false--, "Invalid Interface Eye Trace Entity"
	end
	if not table.HasValue(children, ent) then
		return false--, "Interface Eye Trace Entity is not a child of the Trigger Entity."
	end

	return true, ent
end

-- Create a window of a given time and the given data.
--
-- @param String windowType
-- @param Vector pos
-- @param Angle angles
-- @param Number scale
-- @param Number widht
-- @param Number height
-- @param? vararg ...
-- @return Boolean Success
-- @return? String/Table error/windowData
function Star_Trek.LCARS:CreateWindow(windowType, pos, angles, scale, width, height, callback, ...)
	local windowFunctions = self.Windows[windowType]
	if not istable(windowFunctions) then
		return false, "Invalid Window Type!"
	end

	local windowData = {
		WindowType = windowType,

		WindowPos = pos,
		WindowAngles = angles,

		WindowScale = scale or 20,
		WindowWidth = width or 300,
		WindowHeight = height or 300,

		Callback = callback,
	}

	windowData = windowFunctions.OnCreate(windowData, ...)
	if not istable(windowData) then
		return false, "Invalid Window Data!"
	end

	return true, windowData
end

function Star_Trek.LCARS:CombineWindows(...)
	local windows = {}

	for i, windowData in ipairs({...}) do
		windows[i] = windowData
		windowData.WindowId = i
	end

	return windows
end

-- TODO: Sync on Join Active Interfaces

-- Closing the panel when you are too far away.
-- This is also done clientside so we don't need to network.
hook.Add("Think", "Star_Trek.LCARS.ThinkClose", function()
	local removeInterfaces = {}
	for ent, interfaceData in pairs(Star_Trek.LCARS.ActiveInterfaces) do
		if not IsValid(ent) then
			table.insert(removeInterfaces, ent)
			continue
		end

		local entities = ents.FindInSphere(interfaceData.InterfacePos, 128)
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

function Star_Trek.LCARS:UpdateWindow(ent, windowId)
	local interfaceData = self.ActiveInterfaces[ent]

	local windowDataClient = table.Copy(interfaceData.Windows[windowId])
	windowDataClient.Callback = nil

	net.Start("Star_Trek.LCARS.Update")
		net.WriteInt(ent:EntIndex(), 32)
		net.WriteInt(windowId, 32)
		net.WriteTable(windowDataClient)
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

	local windowFunctions = Star_Trek.LCARS.Windows[windowData.WindowType]
	if not istable(windowFunctions) then
		return
	end

	local updated = windowFunctions.OnPress(windowData, interfaceData, ent, buttonId, windowData.Callback)
	if updated then
		Star_Trek.LCARS:UpdateWindow(ent, windowId)
	end
end)

function Star_Trek.LCARS:LoadInterfaces()
	local _, directories = file.Find("star_trek/lcars/interfaces/*", "LUA")

	for _, interfaceName in pairs(directories) do
		include("interfaces/" .. interfaceName .. "/init.lua")

		Star_Trek:Message("Loaded LCARS Interface \"" .. interfaceName .. "\"")
	end
end

Star_Trek.LCARS:LoadInterfaces()
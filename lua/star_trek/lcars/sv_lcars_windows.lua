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
--       LCARS Windows | Server      --
---------------------------------------

------------------------
--       Opening      --
------------------------

-- Create a window of a given type and the given data.
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
	setmetatable(windowData, {__index = windowFunctions})

	local success = windowData:OnCreate(...)
	if not success then
		return false, "Invalid Window Data!"
	end

	return true, windowData
end

-- Applies Offset and Values to a Window.
--
-- @param Table interfaceData
-- @param Number windowId
-- @param Table windowData
function Star_Trek.LCARS:ApplyWindow(interfaceData, windowId, windowData)
	local ent = interfaceData.Ent
	if not IsValid(ent) then
		return
	end

	windowData.Id = windowId
	windowData.Interface = interfaceData

	if windowData.AppliedOffset then
		return
	end

	local offsetPos = interfaceData.OffsetPos or Vector()
	local offsetAng = interfaceData.OffsetAng or Angle()
	if isvector(offsetPos) and isangle(offsetAng) then
		local newPosOrig, newAngOrig = LocalToWorld(offsetPos, offsetAng, ent:GetPos(), ent:GetAngles())
		local newPosWorld, newAngWorld = LocalToWorld(windowData.WindowPos, windowData.WindowAngles, newPosOrig, newAngOrig)
		windowData.WindowPos, windowData.WindowAngles = WorldToLocal(newPosWorld, newAngWorld, ent:GetPos(), ent:GetAngles())
	end

	windowData.AppliedOffset = true
end

------------------------
--      Updating      --
------------------------

util.AddNetworkString("Star_Trek.LCARS.Update")

-- Updates the window of the given id.
--
-- @param Entity ent
-- @param Number windowId
-- @param? Table windowData
function Star_Trek.LCARS:UpdateWindow(ent, windowId, windowData)
	local interfaceData = self.ActiveInterfaces[ent]
	if not istable(interfaceData) then
		return
	end

	if istable(windowData) then
		interfaceData.Windows[windowId] = windowData
	end

	windowData = interfaceData.Windows[windowId]

	Star_Trek.LCARS:ApplyWindow(interfaceData, windowId, windowData)

	-- Spam Protection
	local timerName = "Star_Trek.LCARS.Update." .. ent:EntIndex() .. "." .. windowId
	if timer.Exists(timerName) then
		return
	end

	-- Delayed Spam Protection
	timer.Create(timerName, 0, 1, function()
		timer.Remove(timerName)

		-- Get Current Client Data.
		local clientWindowData = windowData:GetClientData()

		-- Networking
		net.Start("Star_Trek.LCARS.Update")
			net.WriteInt(ent:EntIndex(), 32)
			net.WriteInt(windowId, 32)
			Star_Trek.Util:WriteNetTable(clientWindowData)
		net.Broadcast()
	end)
end
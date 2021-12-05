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
--        LCARS Util | Server        --
---------------------------------------

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
		return false, "Invalid Interface Eye Trace Entity"
	end
	if not table.HasValue(children, ent) then
		return false, "Interface Eye Trace Entity is not a child of the Trigger Entity."
	end

	return true, ent
end

-- Retrieves the global position and angle of the center of the created interface for that entity.
-- Uses either the origin or an "button" attachment point of the entity.
--
-- @param Entity ent
-- @return Vector globalInterfacePos
-- @return Angle globalInterfaceAngle
function Star_Trek.LCARS:GetInterfacePosAngleGlobal(ent)
	local globalInterfacePos = ent:GetPos()
	local globalInterfaceAngle = ent:GetUp():Angle()

	-- If "movedir" keyvalue is set, then override globalInterfaceAngle
	local moveDir = ent:GetKeyValues()["movedir"]
	if isvector(moveDir) then
		globalInterfaceAngle = moveDir:Angle()
	end

	-- If an "button" attachment exists on the model of the entity, then that is used instead.
	local attachmentID = ent:LookupAttachment("button")
	if isnumber(attachmentID) and attachmentID > 0 then
		local attachmentPoint = ent:GetAttachment(attachmentID)
		globalInterfacePos = attachmentPoint.Pos
		globalInterfaceAngle = attachmentPoint.Ang
	end

	globalInterfaceAngle:RotateAroundAxis(globalInterfaceAngle:Right(), -90)
	globalInterfaceAngle:RotateAroundAxis(globalInterfaceAngle:Up(), 90)

	return globalInterfacePos, globalInterfaceAngle
end

-- Retrieves the Interface Position and Angle relative to the entitiy.
--
-- @param Entity ent
-- @return Vector localInterfacePos
-- @return Angle localInterfaceAngle
function Star_Trek.LCARS:GetInterfacePosAngle(ent)
	local globalInterfacePos, globalInterfaceAngle = Star_Trek.LCARS:GetInterfacePosAngleGlobal(ent)
	local localInterfacePos, localInterfaceAngle = WorldToLocal(globalInterfacePos, globalInterfaceAngle, ent:GetPos(), ent:GetAngles())

	return localInterfacePos, localInterfaceAngle
end

------------------------
--   Network Filters  --
------------------------

-- Returns filtered windowData, that can be safely transmitted to the client without issues.
--
-- @param Table windowData
-- @return Table clientWindowData
function Star_Trek.LCARS:GetClientWindowData(windowData)
	local clientWindowData = table.Copy(windowData)
	for id, data in pairs(windowData) do
		if isfunction(data) then
			clientWindowData[id] = nil
		end
	end

	-- Prevent Recursion
	clientWindowData.Interface = nil

	clientWindowData.AppliedOffset = nil

	return clientWindowData
end

-- Returns filtered interfaceData, that can be safely transmitted to the client without issues.
--
-- @param Table interfaceData
-- @return Table clientInterfaceData
function Star_Trek.LCARS:GetClientInterfaceData(interfaceData)
	local clientInterfaceData = table.Copy(interfaceData)
	for id, data in pairs(interfaceData) do
		if isfunction(data) then
			clientInterfaceData[id] = nil
		end
	end

	clientInterfaceData.OffsetPos = nil
	clientInterfaceData.OffsetAng = nil

	clientInterfaceData.Windows = {}
	for id, windowData in pairs(interfaceData.Windows) do
		clientInterfaceData.Windows[id] = self:GetClientWindowData(windowData)
	end

	return clientInterfaceData
end


------------------------
--  Vehicle E Button  --
------------------------

util.AddNetworkString("Star_Trek.LCARS.DisableEButton")
hook.Add("PlayerEnteredVehicle", "", function(ply, veh, seat)
	net.Start("Star_Trek.LCARS.DisableEButton")
	net.Send(ply)
end)
util.AddNetworkString("Star_Trek.LCARS.EnableEButton")
hook.Add("PlayerLeaveVehicle", "", function(ply, veh)
	net.Start("Star_Trek.LCARS.EnableEButton")
	net.Send(ply)
end)
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
--        LCARS Util | Server        --
---------------------------------------

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

	local modelSetting = self.ModelSettings[ent:GetModel()]
	if istable(modelSetting) then
		globalInterfacePos = globalInterfacePos + globalInterfaceAngle:Forward() * modelSetting.Offset
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

	clientWindowData.Interface = nil

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
	clientInterfaceData.Windows = {}

	for id, windowData in pairs(interfaceData.Windows) do
		clientInterfaceData.Windows[id] = self:GetClientWindowData(windowData)
	end

	return clientInterfaceData
end

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
function Star_Trek.LCARS:CreateWindow(windowType, pos, angles, scale, width, height, callback, ...) -- TODO: Rework as self:CreateWindow on the interface Data?
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

-- Returns categoriy data for a category_list containing all ship sections.
-- 
-- @param bool? needsLocations
-- @return Table categories
function Star_Trek.LCARS:GetSectionCategories(needsLocations)
	local categories = {}
	for deck, deckData in SortedPairs(Star_Trek.Sections.Decks) do
		local category = {
			Name = "DECK " .. deck,
			Buttons = {},
		}

		if table.Count(deckData.Sections) == 0 then
			category.Disabled = true
		else
			for sectionId, sectionData in SortedPairs(deckData.Sections) do
				local button = {
					Name = Star_Trek.Sections:GetSectionName(deck, sectionId),
					Data = sectionData.Id,
				}

				if needsLocations and table.Count(sectionData.BeamLocations) == 0 then
					button.Disabled = true
				end

				table.insert(category.Buttons, button)
			end
		end

		table.insert(categories, category)
	end

	return categories
end
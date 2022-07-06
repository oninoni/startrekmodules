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
--          Control | Server         --
---------------------------------------

Star_Trek.Control.INACTIVE    = 0
Star_Trek.Control.ACTIVE      = 1
Star_Trek.Control.INOPERATIVE = 2

-- Register a Control Type.
--
-- @param String name
function Star_Trek.Control:Register(name, callback)
	Star_Trek.Control.Types = Star_Trek.Control.Types or {}

	local controlType = {}
	controlType.Callback = callback

	Star_Trek.Control.Types[name] = controlType
end

-- Clean up all Sections on a deck, that are not broken.
--
-- @param Table deckData
local function cleanupDeck(deckData)
	local sectionIds = {}
	for sectionId, value in ipairs(deckData) do
		if value ~= Star_Trek.Control.INOPERATIVE then
			table.insert(sectionIds, sectionId)
		end
	end

	for _, sectionId in pairs(sectionIds) do
		deckData[sectionId] = nil
	end
end

-- Set the status of a control type.
--
-- @param String name
-- @param Number value
-- @param? Number deck
-- @param? Number sectionId
-- @return Boolean success
-- @return? String error
function Star_Trek.Control:SetStatus(name, value, deck, sectionId)
	local controlType = Star_Trek.Control.Types[name]
	if not istable(controlType) then
		return false, "Invalid Control Type"
	end

	if isnumber(deck) and isnumber(sectionId) then
		local success, sectionData = Star_Trek.Sections:GetDeck(deck, sectionId)
		if not success then
			return false, sectionData
		end

		if isfunction(controlType.Callback) then
			controlType.Callback(value, deck, sectionId)
		end

		controlType[deck] = controlType[deck] or {}
		controlType[deck][sectionId] = value

		return true
	end

	if isnumber(deck) then
		local success, deckData = Star_Trek.Sections:GetDeck(deck)
		if not success then
			return false, deckData
		end

		if isfunction(controlType.Callback) then
			controlType.Callback(value, deck)
		end

		-- Clean up Sections Stuff.
		cleanupDeck(deckData)

		controlType[deck] = controlType[deck] or {}
		controlType[deck].Value = value

		return true
	end

	if isfunction(controlType.Callback) then
		controlType.Callback(value)
	end

	controlType.Value = value
	for _, deckData in ipairs(controlType) do
		-- Clean up Deck Wide Stuff.
		if deckData.Value ~= Star_Trek.Control.INOPERATIVE then
			deckData.Value = nil
		end

		-- Clean up Sections Stuff.
		cleanupDeck(deckData)
	end

	return true
end

-- Get the status of a control type.
-- If the deck and sectionId is given it checks the specified area, falling back to a lower level if not set.
--
-- @param String name
-- @param? Number deck
-- @param? Number sectionId
-- @return? String/Number error/value
function Star_Trek.Control:GetStatus(name, deck, sectionId)
	local controlType = Star_Trek.Control.Types[name]
	if not istable(controlType) then
		return Star_Trek.Control.INACTIVE
	end

	local overrideStatus = hook.Run("Star_Trek.Control.GetStatus", name, deck, sectionId)
	if isnumber(overrideStatus) then
		return overrideStatus
	end

	if isnumber(deck) then
		local deckData = controlType[deck]
		if istable(deckData) then

			if isnumber(sectionId) then
				local sectionValue = deckData[sectionId]
				if isnumber(sectionValue) then
					return sectionValue
				end
			end

			local deckValue = deckData.Value
			if isnumber(deckValue) then
				return deckValue
			end
		end
	end

	local globalValue = controlType.Value
	if isnumber(globalValue) then
		return globalValue
	end

	return Star_Trek.Control.ACTIVE
end
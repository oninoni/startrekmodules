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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--      Turbolift Path | Server      --
---------------------------------------

-- Returns the deck Number of the given turbolift.
--
-- @param Table liftData
-- @return? Number deckNumber
function Star_Trek.Turbolift:GetDeckNumber(liftData)
	if istable(liftData) then
		local name = liftData.Name
		if isstring(name) then
			local deckNumber = tonumber(string.sub(name, 6, 7))
			if isnumber(deckNumber) then
				return deckNumber
			end
		end
	end
end

local ud = "UD"
local sides = "LRBF"
-- Returns the path, that the lift needs to take in its animation, to reach the target decks.
--
-- @param Number sourceDeck
-- @param Number targetDeck
-- @return String travelPath
function Star_Trek.Turbolift:GetPath(sourceDeck, targetDeck)
	local deckDiff = math.abs(targetDeck - sourceDeck)
	if deckDiff == 0 then -- Same Deck Travel
		-- Calculating time with Advantage! :D
		local travelTime = math.min(
			math.random(self.MinTime, self.MaxTime),
			math.random(self.MinTime, self.MaxTime)
		)

		local evadeDirection = ud[math.random(1, 2)]
		if sourceDeck == 1 or sourceDeck == 2 then
			evadeDirection = "D"
		end
		if sourceDeck == 15 then
			evadeDirection = "U"
		end

		local travelPath = "D"
		if evadeDirection == "D" then
			travelPath = "U"
		end

		for i = 1, travelTime-2 do
			if math.random(1, 2) == 1 or i == 1 then
				travelPath = travelPath .. sides[math.random(1, 4)]
			else
				travelPath = travelPath .. travelPath[#travelPath]
			end
		end

		travelPath = travelPath .. evadeDirection

		return travelPath
	else -- Other Deck Travel
		local travelTime = math.min(
			self.MaxTime,
			math.max(
				self.MinTime,
				math.random(deckDiff + 2, deckDiff * 2)
			)
		)

		local travelDirection = "D"
		if sourceDeck > targetDeck then
			travelDirection = "U"
		end

		local travelPath = ""
		local vertTravelled = 0

		for i = 1, travelTime do
			if vertTravelled == deckDiff then
				travelPath = travelPath .. sides[math.random(1, 4)]
			else
				if (travelTime - i) > vertTravelled then
					if math.random(1, 2) == 1 then
						travelPath = travelPath .. travelDirection
						vertTravelled = vertTravelled + 1
					else
						travelPath = travelPath .. sides[math.random(1, 4)]
					end
				else
					travelPath = travelPath .. travelDirection
					vertTravelled = vertTravelled + 1
				end
			end
		end

		return travelPath, #travelPath
	end
end

-- Retuns the path for the given lift entries.
--
-- @param Table sourceLiftData
-- @param Table targetLiftData
-- @return String travelPath
function Star_Trek.Turbolift:GetFullPath(sourceLiftData, targetLiftData)
	local sourceDeck = self:GetDeckNumber(sourceLiftData)
	local targetDeck = self:GetDeckNumber(targetLiftData)

	return self:GetPath(sourceDeck, targetDeck)
end

-- Returns the current deck a traveling lift is currently at.
--
-- @param Table targetLiftData
-- @param String path
-- @param Number travelTimeLeft
-- @return Number currentDeck
function Star_Trek.Turbolift:GetCurrentDeck(targetLiftData, path, travelTimeLeft)
	local totalTravelDistance = 0
	local travelDirection = nil

	for i = 1, #path do
		local c = path[i]
		if c == "D" or c == "U" then
			if not travelDirection then
				travelDirection = c
			end

			totalTravelDistance = totalTravelDistance + 1
		end
	end

	local traveledDistance = 0
	for i = 1, #path - travelTimeLeft do
		local c = path[i]
		if c == "D" or c == "U" then
			traveledDistance = traveledDistance + 1
		end
	end

	local leftOverDistance = totalTravelDistance - traveledDistance
	local targetDeck = self:GetDeckNumber(targetLiftData)

	local currentDeck = targetDeck - leftOverDistance
	if travelDirection == "U" then
		currentDeck = targetDeck + leftOverDistance
	end

	return currentDeck
end


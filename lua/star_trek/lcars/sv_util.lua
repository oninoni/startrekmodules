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

-- Returns the 2digit LCARS Number as a string.
--
-- @param? Number value
-- @return String smallNumber
function Star_Trek.LCARS:GetSmallNumber(value)
	if not (isnumber(value) and value >= 0 and value < 100) then
		value = math.random(0, 99)
	end

	if value < 10 then
		return "0" .. tostring(value)
	else
		return tostring(value)
	end
end

-- Returns the 6digit LCARS Number as a string.
--
-- @param? Number value
-- @return String largeNumber
function Star_Trek.LCARS:GetLargeNumber(value)
	if not (isnumber(value) and value >= 0 and value < 1000000) then
		value = math.random(0, 999999)
	end

	local largeNumber = ""

	if value < 10 then
		largeNumber = "00000" .. tostring(value)
	elseif value < 100 then
		largeNumber = "0000" .. tostring(value)
	elseif value < 1000 then
		largeNumber = "000" .. tostring(value)
	elseif value < 10000 then
		largeNumber = "00" .. tostring(value)
	elseif value < 100000 then
		largeNumber = "0" .. tostring(value)
	else
		largeNumber = tostring(value)
	end

	return string.sub(largeNumber, 1, 2) .. "-" .. string.sub(largeNumber, 3)
end

-- Returns categoriy data for a category_list containing all ship sections.
-- 
-- @param bool? needsLocations
-- @return Table categories
function Star_Trek.LCARS:GetSectionCategories(needsLocations)
	local categories = {}
	for deck, deckData in SortedPairs(Star_Trek.Sections.Decks) do
		local category = {
			Name = "Deck " .. deck,
			Buttons = {},
		}

		if table.Count(deckData.Sections) == 0 then
			category.Disabled = true
		else
			for sectionId, sectionData in SortedPairs(deckData.Sections) do
				local button = {
					Name = "Section " .. sectionData.RealId .. " " .. sectionData.Name,
					Data = sectionData,
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
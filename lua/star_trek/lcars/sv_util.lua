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
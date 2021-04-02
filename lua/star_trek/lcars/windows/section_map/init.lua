function WINDOW.OnCreate(windowData, deck, hFlip)
	windowData.DeckId = deck
	windowData.HFlip = hFlip or false
	
	windowData.Sections = {}
	windowData.DeckName = "Deck " .. deck

	local deckData = Star_Trek.Sections.Decks[deck]
	for sectionId, sectionData in pairs(deckData.Sections) do
		local sectionButtonData = {
			Id = sectionId,
			Name = sectionData.Name,
			Selected = false,
			Areas = {},
		}

		for _, areaData in pairs(sectionData.Areas) do
			local areaButtonData = {}

			areaButtonData.Width = math.abs(areaData.Min.x) + math.abs(areaData.Max.x)
			areaButtonData.Height = math.abs(areaData.Min.y) + math.abs(areaData.Max.y)
			areaButtonData.Pos = areaData.Pos - Vector(0, 200, 0) + Vector(areaData.Min.x + areaData.Max.x, areaData.Min.y + areaData.Max.y, 0)
			areaButtonData.Pos.y = -areaButtonData.Pos.y

			areaButtonData.Pos = areaButtonData.Pos - Vector(areaButtonData.Width / 2, areaButtonData.Height / 2, 0)

			table.insert(sectionButtonData.Areas, areaButtonData)
		end

		table.insert(windowData.Sections, sectionButtonData)
	end

	return windowData
end

function WINDOW.GetSelected(windowData)
	local data = {}

	for _, sectionData in pairs(windowData.Sections) do
		data[sectionData.Id] = sectionData.Selected
	end

	return data
end

function WINDOW.SetSelected(windowData, data)
	for _, sectionData in pairs(windowData.Sections) do
		for id, selected in pairs(data) do
			if id == sectionData.Id then
				sectionData.Selected = selected
			end
		end
	end
end

function WINDOW.OnPress(windowData, interfaceData, ent, buttonId, callback)
	local shouldUpdate = false

	return shouldUpdate
end
CENTER_POS = Vector(0, -200, 0)
MAP_SCALE = 6

function WINDOW.OnCreate(windowData, deck)
	windowData.DeckId = deck
	local deckData = Star_Trek.Sections.Decks[deck]

	windowData.Sections = {}
	windowData.DeckName = "Deck " .. deck

	for sectionId, sectionData in pairs(deckData.Sections) do
		local sectionButtonData = {
			Id = sectionId,
			Name = sectionData.Name,
			Areas = {},
		}
		print(sectionData.Name)

		for _, areaData in pairs(sectionData.Areas) do
			local areaButtonData = {}

			areaButtonData.Width = (math.abs(areaData.Min.x) + math.abs(areaData.Max.x)) / MAP_SCALE
			areaButtonData.Height = (math.abs(areaData.Min.y) + math.abs(areaData.Max.y)) / MAP_SCALE
			areaButtonData.Pos = CENTER_POS + areaData.Pos + Vector(areaData.Min.x + areaData.Max.x, areaData.Min.y + areaData.Max.y, 0)

			if areaButtonData.Pos.z > 1000 then
				local sectionEntities = Star_Trek.Sections:GetInSection(deck, sectionId, true, true)

				local offset
				for _, ent in pairs(sectionEntities) do
					if ent:GetClass() == "linked_portal_door" then
						offset = ent:GetPos() - ent:GetExit():GetPos()
					end
				end

				print(offset)

				--if offset then
				--	areaButtonData.Pos = areaButtonData.Pos - Vector(offset.x , 0, 0)
				--end
			end

			areaButtonData.Pos.y = -areaButtonData.Pos.y
			areaButtonData.Pos.z = 0
			areaButtonData.Pos = areaButtonData.Pos / MAP_SCALE

			table.insert(sectionButtonData.Areas, areaButtonData)
		end

		table.insert(windowData.Sections, sectionButtonData)
	end

	return windowData
end

function WINDOW.GetSelected(windowData)

end

function WINDOW.SetSelected(windowData, data)

end

function WINDOW.OnPress(windowData, interfaceData, ent, buttonId, callback)
	local shouldUpdate = false

	return shouldUpdate
end
function WINDOW:OnCreate(deck, hFlip)
	self.DeckId = deck
	self.HFlip = hFlip or false
	
	self.Sections = {}
	self.DeckName = "DECK " .. deck

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

		table.insert(self.Sections, sectionButtonData)
	end

	return self
end

function WINDOW:GetSelected()
	local data = {}

	for _, sectionData in pairs(self.Sections) do
		data[sectionData.Id] = sectionData.Selected
	end

	return data
end

function WINDOW:SetSelected(data)
	for _, sectionData in pairs(self.Sections) do
		for id, selected in pairs(data) do
			if id == sectionData.Id then
				sectionData.Selected = selected
			end
		end
	end
end

function WINDOW:OnPress(interfaceData, ent, buttonId, callback)
	local shouldUpdate = false

	return shouldUpdate
end
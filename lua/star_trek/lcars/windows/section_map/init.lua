CENTER_POS = Vector(0, -200, 0)
MAP_SCALE = 6

function WINDOW.OnCreate(windowData, sections, deckName)
	windowData.Sections = {}
	windowData.DeckName = deckName or ""

	for id, sectionData in pairs(sections) do
		local sectionButtonData = {
			Name = sectionData.Name,
			Areas = {},
		}

		for _, areaData in pairs(sectionData.Data.Areas) do
			local areaButtonData = {}

			areaButtonData.Width = (math.abs(areaData.Min.x) + math.abs(areaData.Max.x)) / MAP_SCALE
			areaButtonData.Height = (math.abs(areaData.Min.y) + math.abs(areaData.Max.y)) / MAP_SCALE
			areaButtonData.Pos = CENTER_POS + areaData.Pos + Vector(areaData.Min.x + areaData.Max.x, areaData.Min.y + areaData.Max.y, 0)

			if areaButtonData.Pos.z > 1000 then
				areaButtonData.Pos = areaButtonData.Pos + Vector(300 , 0, 0)
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
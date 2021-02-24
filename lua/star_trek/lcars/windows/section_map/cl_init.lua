function WINDOW.OnCreate(self, windowData)
	self.DeckName = windowData.DeckName
	self.Sections = windowData.Sections

	self.FrameMaterialData = Star_Trek.LCARS:CreateFrame(self.Id, self.WWidth, self.WHeight, self.DeckName)

	return self
end

function WINDOW.OnPress(self, pos, animPos)

end

function WINDOW.OnDraw(self, pos, animPos)
	local alpha = 255 * animPos

	for _, sectionData in pairs(self.Sections) do
		sectionData.Hovered = false

		for _, areaData in pairs(sectionData.Areas) do
			local x = areaData.Pos.x - areaData.Width / 2
			local y = areaData.Pos.y - areaData.Height / 2
			local width = areaData.Width
			local height = areaData.Height

			if isvector(pos) and pos.x >= (x -1) and pos.x <= (x + width) and pos.y >= (y -1) and pos.y <= (y + height) then
				sectionData.Hovered = true
			end
		end

		for _, areaData in pairs(sectionData.Areas) do
			local x = areaData.Pos.x - areaData.Width / 2
			local y = areaData.Pos.y - areaData.Height / 2
			local width = areaData.Width
			local height = areaData.Height

			draw.RoundedBox(0, x, y, width, height, sectionData.Hovered and Star_Trek.LCARS.ColorWhite or Star_Trek.LCARS.ColorBlack)
			draw.RoundedBox(0, x + 1, y + 1, width - 2, height - 2, sectionData.Selected and Star_Trek.LCARS.ColorOrange or Star_Trek.LCARS.ColorBlue)
		end
	end

	for _, sectionData in pairs(self.Sections) do
		if sectionData.Hovered then
			draw.SimpleText(sectionData.Name, "LCARSSmall", pos.x, pos.y, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end

	surface.SetDrawColor(255, 255, 255, alpha)

	Star_Trek.LCARS:RenderMaterial(-self.WD2, -self.HD2, self.WWidth, self.WHeight, self.FrameMaterialData)

	surface.SetAlphaMultiplier(1)
end
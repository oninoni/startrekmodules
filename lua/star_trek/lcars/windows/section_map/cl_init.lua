MAP_SCALE = 6

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

	cam.End3D2D()
	cam.Start3D2D(self.WPos, self.WAng, 1 / (self.WScale * MAP_SCALE))
	
	for _, sectionData in pairs(self.Sections) do
		for _, areaData in pairs(sectionData.Areas) do
			local x = areaData.Pos.x -- areaData.Width / 2
			local y = areaData.Pos.y -- areaData.Height / 2
			local width = areaData.Width
			local height = areaData.Height

			draw.RoundedBox(0, x - 1 * MAP_SCALE, y - 1 * MAP_SCALE, width + 2 * MAP_SCALE, height + 2 * MAP_SCALE, Star_Trek.LCARS.ColorBlack)
		end
	end

	for _, sectionData in pairs(self.Sections) do
		for _, areaData in pairs(sectionData.Areas) do
			local x = areaData.Pos.x -- areaData.Width / 2
			local y = areaData.Pos.y -- areaData.Height / 2
			local width = areaData.Width
			local height = areaData.Height

			draw.RoundedBox(0, x, y, width, height, sectionData.Selected and Star_Trek.LCARS.ColorOrange or Star_Trek.LCARS.ColorBlue)
		end
	end

	cam.End3D2D()
	cam.Start3D2D(self.WPos, self.WAng, 1 / self.WScale)

	surface.SetDrawColor(255, 255, 255, alpha)

	Star_Trek.LCARS:RenderMaterial(-self.WD2, -self.HD2, self.WWidth, self.WHeight, self.FrameMaterialData)

	surface.SetAlphaMultiplier(1)
end
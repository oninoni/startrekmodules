local MAP_SCALE = 5
local MAP_OFFSET_X = 0
local MAP_OFFSET_Y = -200

function WINDOW.OnCreate(self, windowData)
	self.DeckName = windowData.DeckName
	self.Sections = windowData.Sections
	self.HFlip = windowData.HFlip

	self.FrameMaterialData = Star_Trek.LCARS:CreateFrame(
		self.Id,
		self.WWidth,
		self.WHeight,
		"",
		self.DeckName,
		Star_Trek.LCARS.ColorLightRed,
		Star_Trek.LCARS.ColorOrange,
		Star_Trek.LCARS.ColorBlue,
		self.HFlip
	)

	return self
end

function WINDOW.OnPress(self, pos, animPos)

end

function WINDOW.OnDraw(self, pos, animPos)
	local alpha = 255 * animPos

	local lcars_black = ColorAlpha(Star_Trek.LCARS.ColorBlack, alpha)
	local lcars_selected = ColorAlpha(Star_Trek.LCARS.ColorOrange, alpha)
	local lcars_inactive = ColorAlpha(Star_Trek.LCARS.ColorBlue, alpha)

	cam.End3D2D()
	cam.Start3D2D(self.WPos, self.WAng, 1 / (self.WScale * MAP_SCALE))
	
	for _, sectionData in pairs(self.Sections) do
		for _, areaData in pairs(sectionData.Areas) do
			local x = areaData.Pos.x + MAP_OFFSET_X
			local y = areaData.Pos.y + MAP_OFFSET_Y
			local width = areaData.Width
			local height = areaData.Height

			draw.RoundedBox(0, x - 1 * MAP_SCALE, y - 1 * MAP_SCALE, width + 2 * MAP_SCALE, height + 2 * MAP_SCALE, lcars_black)
		end
	end

	for _, sectionData in pairs(self.Sections) do
		for _, areaData in pairs(sectionData.Areas) do
			local x = areaData.Pos.x + MAP_OFFSET_X
			local y = areaData.Pos.y + MAP_OFFSET_Y
			local width = areaData.Width
			local height = areaData.Height

			draw.RoundedBox(0, x, y, width, height, sectionData.Selected and lcars_selected or lcars_inactive)
		end
	end

	cam.End3D2D()
	cam.Start3D2D(self.WPos, self.WAng, 1 / self.WScale)

	surface.SetDrawColor(255, 255, 255, alpha)

	Star_Trek.LCARS:RenderFrame(self.FrameMaterialData)

	surface.SetAlphaMultiplier(1)
end
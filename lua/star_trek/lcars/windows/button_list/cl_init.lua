local BUTTON_HEIGHT = 32
-- TODO: Modularize the size of the buttons. (Interaction, Offsets, etc...)

function WINDOW.OnCreate(self, windowData)
	self.Title = windowData.Title
	self.TitleShort = windowData.TitleShort
	self.HFlip = windowData.HFlip
	
	self.Buttons = windowData.Buttons

	self.MaxN = table.maxn(self.Buttons)

	self.ButtonsHeight = self.WHeight - 80
	self.ButtonsStart = self.HD2 - self.ButtonsHeight

	self.ButtonsTopAlpha = self.ButtonsStart
	self.ButtonsBotAlpha = self.HD2 - 25

	self.FrameMaterialData = Star_Trek.LCARS:CreateFrame(
		self.Id,
		self.WWidth,
		self.WHeight,
		self.Title,
		self.TitleShort,
		Star_Trek.LCARS.ColorOrange,
		Star_Trek.LCARS.ColorBlue,
		Star_Trek.LCARS.ColorLightRed,
		self.HFlip
	)

	for id, button in pairs(self.Buttons) do
		button.MaterialData = Star_Trek.LCARS:CreateButton(
			self.Id .. "_" .. id,
			self.WWidth - 64,
			BUTTON_HEIGHT,
			button.Color,
			Star_Trek.LCARS.ColorYellow,
			button.Name or "[ERROR]",
			false,
			false,
			button.RandomL,
			button.RandomS
		)
	end

	return self
end

function WINDOW.OnPress(self, pos, animPos)
	local offset = Star_Trek.LCARS:GetButtonOffset(self.ButtonsStart, self.ButtonsHeight, self.MaxN, pos.y)
	for i, button in pairs(self.Buttons) do
		if button.Disabled then continue end

		local y = Star_Trek.LCARS:GetButtonYPos(self.ButtonsHeight, i, self.MaxN, offset)
		if pos.y >= y - 1 and pos.y <= y + (BUTTON_HEIGHT - 1) then
			return i
		end
	end
end

local color_grey = Star_Trek.LCARS.ColorGrey
local color_yellow = Star_Trek.LCARS.ColorYellow

function WINDOW.OnDraw(self, pos, animPos)

	local offset = Star_Trek.LCARS:GetButtonOffset(self.ButtonsStart, self.ButtonsHeight, self.MaxN, pos.y)
	local x = self.HFlip and -24 or 24
	for i, button in pairs(self.Buttons) do
		local y = Star_Trek.LCARS:GetButtonYPos(self.ButtonsHeight, i, self.MaxN, offset)

		local state = 1
		if not button.Disabled then
			state = 2
			if button.Selected then
				state = state + 1
			end
			if pos.y >= y - 1 and pos.y <= y + (BUTTON_HEIGHT - 1) then
				state = state + 3
			end
		end

		local buttonAlpha = 255
		if y < self.ButtonsTopAlpha or y > self.ButtonsBotAlpha then
			if y < self.ButtonsTopAlpha then
				buttonAlpha = -y + self.ButtonsTopAlpha
			else
				buttonAlpha = y - self.ButtonsBotAlpha
			end

			buttonAlpha = math.min(math.max(0, 255 - buttonAlpha * 10), 255)
		end
		buttonAlpha = math.min(buttonAlpha, 255 * animPos)
		surface.SetDrawColor(255, 255, 255, buttonAlpha)
		
		Star_Trek.LCARS:RenderButton(x, y, button.MaterialData, state)
	end
	
	surface.SetDrawColor(255, 255, 255, 255 * animPos)

	Star_Trek.LCARS:RenderFrame(self.FrameMaterialData)

	surface.SetAlphaMultiplier(1)
end
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
--     LCARS Text Entry | Client     --
---------------------------------------

local SELF = WINDOW
function SELF:OnCreate(windowData)
	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.XOffset = (self.HFlip and -24 or 24)

	self.TextWidth = self.WWidth - 85
	self.TextStartX = self.WD2 - self.XOffset - self.TextWidth

	self.TextHeight = self.WHeight - 80
	self.TextStartY = self.HD2 - self.TextHeight

	self.TextTopAlpha = self.TextStartY + 10
	self.TextBotAlpha = self.HD2 - 10

	self.Offset = self.Offset or self.TextStartY
	self.OffsetDirection = false

	self.FallbackColor = windowData.FallbackColor
	self.Active = windowData.Active

	self:ProcessText(windowData.Lines)

	return true
end

function SELF:CheckLine(words, subLines)
	subLines = subLines or {}

	local newLine = ""
	local newLinePrev = ""
	local lastWord = ""
	while surface.GetTextSize(newLine) < self.TextWidth do
		newLinePrev = newLine
		newLine = newLine .. words[1] .. " "
		lastWord = words[1]
		table.remove(words, 1)

		if table.Count(words) == 0 then
			newLinePrev = newLine
			break
		end
	end

	if newLinePrev ~= newLine then
		table.insert(words, lastWord)
	end
	table.insert(subLines, newLinePrev)

	if table.Count(words) > 0 then
		self:CheckLine(words, subLines)
	end

	return subLines
end

function SELF:ProcessText(lines)
	self.Lines = {}

	-- Prep Font for recursion.
	surface.SetFont("LCARSSmall")

	for _, line in pairs(lines) do
		local words = string.Split(line.Text, " ")

		local subLines = self:CheckLine(words)

		for _, subLine in pairs(subLines) do
			table.insert(self.Lines, {
				Text = subLine,
				Color = line.Color or self.FallbackColor
			})
		end
	end

	self.MaxN = table.maxn(self.Lines)
	self.MaxOffset = -(self.MaxN * 16) + self.HD2
end

function SELF:OnPress(pos, animPos)
	return 1 -- TODO: Check if Text Area was clicked.
end

function SELF:OnDraw(pos, animPos)
	if self.Active
	and pos.x > -self.WD2 and pos.x < self.WD2
	and pos.y > -self.HD2 and pos.y < self.HD2 then
		local offsetTarget = Star_Trek.LCARS:GetButtonOffset(self.TextStartY, self.TextHeight, 16, self.MaxN, pos.y)
		self.Offset = Lerp(0.005, self.Offset, offsetTarget)
	else
		self.Offset = math.max(self.Offset - 10 * FrameTime(), self.MaxOffset)
	end

	for i, line in pairs(self.Lines) do
		local y = self.Offset + i * 16

		local textAlpha = 255
		if y < self.TextTopAlpha or y > self.TextBotAlpha then
			if y < self.TextTopAlpha then
				textAlpha = -y + self.TextTopAlpha
			else
				textAlpha = y - self.TextBotAlpha
			end

			textAlpha = math.min(math.max(0, 255 - textAlpha * 10), 255)
		end
		textAlpha = math.min(textAlpha, 255 * animPos)

		draw.SimpleText(line.Text, "LCARSSmall", self.TextStartX, y, ColorAlpha(line.Color, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	end

	SELF.Base.OnDraw(self, pos, animPos)
end
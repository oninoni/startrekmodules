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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--     LCARS Text Entry | Client     --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(windowData)
	self.Padding = self.Padding or 1
	self.FrameType = self.FrameType or "frame"

	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.TextTopAlpha = self.Area1Y + 20
	self.TextBotAlpha = self.Area1YEnd - 10

	self.Offset = self.Offset or self.Area1Y
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
	while surface.GetTextSize(newLine) < self.Area1Width do
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
	self.MaxOffset = -((self.MaxN + 1) * 16) + self.HD2
end

function SELF:OnPress(pos, animPos)
	if pos.x > self.Area1X and pos.x < self.Area1X + self.Area1Width
	and pos.y > self.Area1Y and pos.y < self.Area1Y + self.Area1Height then
		return 1
	end
end

function SELF:OnDraw(pos, animPos)
	if self.Active then
		local offsetTarget = Star_Trek.LCARS:GetButtonOffset(self.Area1Y, self.Area1Height, 16, self.MaxN, pos[2])
		self.Offset = Lerp(0.005, self.Offset, offsetTarget)
	else
		local offsetTarget = Star_Trek.LCARS:GetButtonOffset(self.Area1Y, self.Area1Height, 16, self.MaxN, self.HD2)
		self.Offset = Lerp(0.005, self.Offset, offsetTarget)
	end

	--draw.RoundedBox(0, 0, self.Area1Y, 10, self.Area1Height, Color(255, 0, 0))

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

		draw.SimpleText(line.Text, "LCARSSmall", self.Area1X, y, ColorAlpha(line.Color, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	end

	SELF.Base.OnDraw(self, pos, animPos)
end
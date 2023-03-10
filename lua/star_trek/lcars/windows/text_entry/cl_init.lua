---------------------------------------
---------------------------------------
--         Star Trek Modules         --
--                                   --
--            Created by             --
--       Jan 'Oninoni' Ziegler       --
--                                   --
-- This software can be used freely, --
--    but only distributed by me.    --
--                                   --
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--     LCARS Text Entry | Client     --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

local SCROLL_EXPONENT = 1.5

function SELF:OnCreate(windowData)
	self.Padding = self.Padding or 1
	self.FrameType = self.FrameType or "frame"

	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.TextTopAlpha = self.Area1Y + 20
	self.TextBotAlpha = self.Area1YEnd - 10

	local h = self.Area1Height / 4
	self.TextTopOffset = self.Area1Y + h
	self.TextBotOffset = self.Area1YEnd - h

	self.FallbackColor = windowData.FallbackColor
	self.Active = windowData.Active

	self.TextHeight = self.TextHeight or 20
	self.TextFont = self.TextFont or "LCARSText"

	self:ProcessText(windowData.Lines)

	self.Offset = self.Offset or self.OffsetTarget or 0
	self.OffsetDirection = false

	return true
end

function SELF:CheckLine(words, subLines)
	subLines = subLines or {}

	local newLine = ""
	local line = ""
	local lastWordId
	for id, word in ipairs(words) do
		if newLine ~= "" then
			newLine = newLine .. " "
		end

		newLine = newLine .. word

		local length = surface.GetTextSize(newLine)
		if length > self.Area1Width - 32 then
			lastWordId = id

			break
		end

		line = newLine
	end

	table.insert(subLines, line)

	-- Recursion
	if isnumber(lastWordId) then
		local newWords = {}
		for i = lastWordId, #words do
			table.insert(newWords, words[i])
		end

		self:CheckLine(newWords, subLines)
	end

	return subLines
end

function SELF:ProcessText(lines)
	local oldMaxOffset = self.MaxOffset or 0

	-- Prep Font for recursion.
	surface.SetFont(self.TextFont)

	self.Lines = {}

	for _, line in pairs(lines or {}) do
		local text = line.Text
		local words = string.Split(text, " ")

		local subLines = self:CheckLine(words)

		for _, subLine in pairs(subLines) do
			table.insert(self.Lines, {
				Text = subLine,
				Color = line.Color or self.FallbackColor,
				Align = line.Align or TEXT_ALIGN_LEFT
			})
		end
	end

	self.MaxOffset = (table.maxn(self.Lines) + 1) * self.TextHeight
	if oldMaxOffset ~= self.MaxOffset then
		self.OffsetTarget = -(self.MaxOffset - self.Area1Height)
	else
		self.OffsetTarget = nil
	end
end

function SELF:OnPress(pos, animPos)
	if pos.x > self.Area1X and pos.x < self.Area1X + self.Area1Width
	and pos.y > self.Area1Y and pos.y < self.Area1Y + self.Area1Height then
		return 1
	end
end

function SELF:OnDraw(pos, animPos)
	local offsetTarget = self.Offset
	if self.Active then
		local y = pos.y
		if y < self.TextTopOffset then
			offsetTarget = math.min(0, self.Offset + math.pow(self.TextTopOffset - y, SCROLL_EXPONENT))
		elseif y > self.TextBotOffset then
			offsetTarget = math.max(self.Offset - math.pow(y - self.TextBotOffset, SCROLL_EXPONENT), -(self.MaxOffset - self.Area1Height))
		end
	else
		if isnumber(self.OffsetTarget) then
			offsetTarget = self.OffsetTarget
		end
	end
	self.Offset = Lerp(0.01, self.Offset, offsetTarget)

	for i, line in pairs(self.Lines) do
		local y = self.Area1Y + self.Offset + i * self.TextHeight

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
		if textAlpha == 0 then continue end

		local align = line.Align
		if align == TEXT_ALIGN_LEFT then
			draw.SimpleText(line.Text, self.TextFont, self.Area1X + 4, y, ColorAlpha(line.Color or Star_Trek.LCARS.ColorLightBlue, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		elseif align == TEXT_ALIGN_RIGHT then
			draw.SimpleText(line.Text, self.TextFont, self.Area1XEnd - 4, y, ColorAlpha(line.Color or Star_Trek.LCARS.ColorLightBlue, textAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		elseif align == TEXT_ALIGN_CENTER then
			draw.SimpleText(line.Text, self.TextFont, self.Area1X + self.Area1Width / 2, y, ColorAlpha(line.Color or Star_Trek.LCARS.ColorLightBlue, textAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		end
	end

	SELF.Base.OnDraw(self, pos, animPos)
end
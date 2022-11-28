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
--    LCARS Button Matrix | Client   --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:CreateButtons(id, buttonList)
	if table.Count(buttonList) == 0 then
		return false, 0
	end

	local buttons = {}

	local y = self.Area1Y
	local yHeight = self.Area1Height
	if id == 2 then
		y = self.Area2Y
		yHeight = self.Area2Height
	end

	buttons.AreaY = y
	buttons.AreaHeight = yHeight
	buttons.AreaYEnd = y + yHeight

	local totalHeight = 0
	for i, buttonRowData in pairs(buttonList) do
		local buttonRowButtons = buttonRowData.Buttons
		local nButtons = table.Count(buttonRowButtons)

		local width = (self.Area1Width - 2 * self.Padding) / nButtons - self.Padding
		local height = buttonRowData.Height - self.Padding

		local x = self.Area1X + self.Padding
		for j, buttonData in pairs(buttonRowButtons) do
			local success, button = self:GenerateElement("button", self.Id .. "_" .. id .. "_" .. i .. "_" .. j, width, height,
				buttonData.Name or "[ERROR]", buttonData.Number,
				buttonData.Color, buttonData.ActiveColor,
				j ~= 1, j ~= nButtons,
				buttonData.Disabled, buttonData.Selected, false)
			if not success then return false end

			button.ButtonId = buttonData.ButtonId
			button.X = x
			button.Y = y

			table.insert(buttons, button)

			x = x + width + self.Padding
		end

		y = y + height + self.Padding
		totalHeight = totalHeight + height + self.Padding
	end

	buttons.TotalHeight = totalHeight - self.Padding

	if #buttons > 0 then
		local firstHeight = buttons[1].ElementHeight
		local finalHeight = buttons[#buttons].ElementHeight
		buttons.AreaYScroll = buttons.AreaY + firstHeight
		buttons.AreaHeightScroll = yHeight - firstHeight - finalHeight
	end

	return buttons
end

function SELF:OnCreate(windowData)
	self.Padding = self.Padding or 1

	local targetFrameType = "frame_double"
	if table.Count(windowData.SecondaryButtons) > 0 then
		targetFrameType = "frame_triple"

		self.SubMenuHeight = self.Padding
		for _, buttonRowData in pairs(windowData.SecondaryButtons) do
			local height = buttonRowData.Height - self.Padding
			self.SubMenuHeight = self.SubMenuHeight + height + self.Padding
		end
	end

	self.FrameType = self.FrameType or targetFrameType

	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.MainButtons = self:CreateButtons(1, windowData.MainButtons)
	self.SecondaryButtons = self:CreateButtons(2, windowData.SecondaryButtons)

	return true
end

function SELF:GetListOffset(yPos, buttons)
	local totalHeight = buttons.TotalHeight
	local areaHeight = buttons.AreaHeight

	local offset = 0
	if totalHeight > areaHeight then
		local relativePos = (yPos - buttons.AreaYScroll) / buttons.AreaHeightScroll
		local overFlow = areaHeight - totalHeight

		offset = relativePos * overFlow
		offset = math.max(math.min(offset, 0), overFlow)
	end

	return offset
end

function SELF:IsButtonHovered(x, y, xEnd, yEnd, pos)
	return pos[1] >= x and pos[1] <= xEnd and pos[2] >= y and pos[2] <= yEnd
end

function SELF:OnPressButtonList(pos, buttons)
	if not istable(buttons) then return end

	local yOffset = SELF:GetListOffset(pos.Y, buttons)
	for _, button in ipairs(buttons) do
		if button.Disabled then continue end

		local x = button.X
		local y = button.Y + yOffset

		if self:IsButtonHovered(x, y, x + button.ElementWidth, y + button.ElementHeight, pos) then
			return button.ButtonId
		end
	end
end

function SELF:OnPress(pos, animPos)
	local buttonId1 = SELF:OnPressButtonList(pos, self.MainButtons)
	if isnumber(buttonId1) then return buttonId1 end

	local buttonId2 = SELF:OnPressButtonList(pos, self.SecondaryButtons)
	if isnumber(buttonId2) then return buttonId2 end
end

function SELF:GetButtonAlpha(y, areaY, areaYEnd, buttonHeight)
	local uDiff = y - areaY
	local bDiff = areaYEnd - (y + buttonHeight)

	local alpha = 255

	local fadeHeight = buttonHeight / 2

	if uDiff < 0 then
		if uDiff < -fadeHeight then
			alpha = 0
		else
			local perc = 1 + (uDiff / fadeHeight)
			alpha = perc * 255
		end
	end
	if bDiff < 0 then
		if bDiff < -fadeHeight then
			alpha = 0
		else
			local perc = 1 + (bDiff / fadeHeight)
			alpha = perc * 255
		end
	end

	return alpha
end

function SELF:DrawButtonList(pos, animPos, buttons)
	if not istable(buttons) then return end

	local yOffset = SELF:GetListOffset(pos.Y, buttons)

	local areaY = buttons.AreaY
	local areaYEnd = buttons.AreaYEnd
	for _, button in ipairs(buttons) do
		local x = button.X
		local y = button.Y + yOffset

		button.Hovered = self:IsButtonHovered(x, y, x + button.ElementWidth, y + button.ElementHeight, pos)

		local alpha = self:GetButtonAlpha(y, areaY, areaYEnd, button.ElementHeight)
		if alpha == 0 then continue end

		surface.SetDrawColor(255, 255, 255, alpha * animPos)

		button:Render(x, y)
	end
end

function SELF:OnDraw(pos, animPos)
	self:DrawButtonList(pos, animPos, self.MainButtons)
	self:DrawButtonList(pos, animPos, self.SecondaryButtons)

	SELF.Base.OnDraw(self, pos, animPos)
end
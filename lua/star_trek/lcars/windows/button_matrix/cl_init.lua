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
		return false
	end

	local buttons = {}

	local y = self.Area1Y
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
	end

	return buttons
end

function SELF:OnCreate(windowData)
	self.Padding = self.Padding or 1

	local targetFrameTime = "frame_double"
	if table.Count(windowData.SecondaryButtons) > 0 then
		targetFrameTime = "frame_triple"
	end

	self.FrameType = self.FrameType or targetFrameTime

	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.MainButtons = self:CreateButtons(1, windowData.MainButtons)
	self.SecondaryButtons = self:CreateButtons(2, windowData.SecondaryButtons)

	return true
end

function SELF:IsButtonHovered(x, y, xEnd, yEnd, pos)
	return pos[1] >= x and pos[1] <= xEnd and pos[2] >= y and pos[2] <= yEnd
end

function SELF:OnPress(pos, animPos)
	for _, button in pairs(self.MainButtons or {}) do
		local x = button.X
		local y = button.Y
		if self:IsButtonHovered(x, y, x + button.ElementWidth, y + button.ElementHeight, pos) then
			return button.ButtonId
		end
	end

	for _, button in pairs(self.SecondaryButtons or {}) do
		local x = button.X
		local y = button.Y
		if self:IsButtonHovered(x, y, x + button.ElementWidth, y + button.ElementHeight, pos) then
			return button.ButtonId
		end
	end
end

function SELF:OnDraw(pos, animPos)
	surface.SetDrawColor(255, 255, 255, 255 * animPos)

	for _, button in pairs(self.MainButtons or {}) do
		local x = button.X
		local y = button.Y
		button.Hovered = self:IsButtonHovered(x, y, x + button.ElementWidth, y + button.ElementHeight, pos)
		button:Render(x, y)
	end

	for _, button in pairs(self.SecondaryButtons or {}) do
		button:Render(button.X, button.Y)
	end

	SELF.Base.OnDraw(self, pos, animPos)
end
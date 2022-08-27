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
--    LCARS Button Matrix | Server   --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(title, titleShort, hFlip)
	local success = SELF.Base.OnCreate(self, title, titleShort, hFlip)
	if not success then
		return false
	end

	self.Buttons = {}

	self.MainButtons = {}
	self.SecondaryButtons = {}

	return true
end

function SELF:ClearButtonsInternal(buttonList)
	for _, buttonRowData in pairs(buttonList or {}) do
		for _, buttonData in pairs(buttonRowData.Buttons or {}) do
			table.RemoveByValue(self.Buttons, buttonData)
		end
	end

	for i, buttonData in pairs(self.Buttons) do
		buttonData.ButtonId = i
	end
end

function SELF:ClearMainButtons()
	self:ClearButtonsInternal(self.MainButtons)
	self.MainButtons = {}
end

function SELF:ClearSecondaryButtons()
	self:ClearButtonsInternal(self.SecondaryButtons)
	self.SecondaryButtons = {}
end

function SELF:CreateButtonRow(buttonList, height)
	local buttonRowData = {}

	buttonRowData.Height = height

	table.insert(buttonList, buttonRowData)
	buttonRowData.ColorOffset = table.Count(buttonList) % 2

	buttonRowData.Buttons = {}

	return buttonRowData
end

function SELF:CreateMainButtonRow(height)
	return self:CreateButtonRow(self.MainButtons, height)
end

function SELF:CreateSecondaryButtonRow(height)
	return self:CreateButtonRow(self.SecondaryButtons, height)
end

function SELF:AddButtonToRow(buttonRowData, name, number, color, activeColor, disabled, toggle, callback)
	local buttonData = {}

	buttonData.Name = name or "MISSING"
	buttonData.Number = number

	if IsColor(color) then
		buttonData.Color = color
	else
		if table.Count(buttonRowData) % 2 == buttonRowData.ColorOffset then
			buttonData.Color = Star_Trek.LCARS.ColorLightBlue
		else
			buttonData.Color = Star_Trek.LCARS.ColorBlue
		end
	end

	buttonData.ActiveColor = activeColor or Star_Trek.LCARS.ColorOrange
	buttonData.Disabled = disabled

	buttonData.Toggle = toggle
	buttonData.Callback = callback

	buttonData.ButtonId = table.insert(self.Buttons, buttonData)

	table.insert(buttonRowData.Buttons, buttonData)

	return buttonData
end

function SELF:GetButtonClientData(buttonList)
	local clientButtonList = {}

	for _, buttonRowData in pairs(buttonList) do
		local clientButtonRowData = {
			Height = buttonRowData.Height,

			Buttons = {}
		}

		for _, buttonData in pairs(buttonRowData.Buttons) do
			local clientButtonData = {
				ButtonId = buttonData.ButtonId,
				Name = buttonData.Name,
				Disabled = buttonData.Disabled,
				Selected = buttonData.Selected,

				Color = buttonData.Color,
				ActiveColor = buttonData.ActiveColor,

				Number = buttonData.Number,
			}

			table.insert(clientButtonRowData.Buttons, clientButtonData)
		end

		table.insert(clientButtonList, clientButtonRowData)
	end

	return clientButtonList
end

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	local buttonData = self.Buttons[buttonId]
	if not istable(buttonData) then return end

	local overrideSound = false
	if isfunction(buttonData.Callback) and buttonData.Callback() then
		overrideSound = true
	end

	if not overrideSound then
		interfaceData.Ent:EmitSound("star_trek.lcars_beep")
	end

	return true
end

function SELF:GetClientData()
	local clientData = SELF.Base.GetClientData(self)

	clientData.MainButtons = self:GetButtonClientData(self.MainButtons)
	clientData.SecondaryButtons = self:GetButtonClientData(self.SecondaryButtons)

	return clientData
end
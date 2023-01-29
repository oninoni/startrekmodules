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

function SELF:OnCreate(title, titleShort, hFlip, maxListHeight)
	local success = SELF.Base.OnCreate(self, title, titleShort, hFlip)
	if not success then
		return false
	end

	self.Buttons = {}

	self.MaxListHeight = maxListHeight
	self.PageSelectorHeight = 32 -- TODO: Changeable?

	self:ClearMainButtons()
	self:ClearSecondaryButtons()

	return true
end

function SELF:ClearButtonsInternal(buttonList)
	for _, buttonRowData in pairs(buttonList or {}) do
		for _, buttonData in pairs(buttonRowData.Buttons or {}) do
			table.RemoveByValue(self.Buttons, buttonData)
		end
	end

	for i, buttonData in pairs(self.Buttons or {}) do
		buttonData.ButtonId = i
	end
end

function SELF:ClearMainButtons()
	self:ClearButtonsInternal(self.MainButtons)

	self.MainButtons = {}

	if isnumber(self.MaxListHeight) then
		self.Page = 1
		self.Pages = {{}}
	end
end

function SELF:ClearSecondaryButtons()
	self:ClearButtonsInternal(self.SecondaryButtons)
	self.SecondaryButtons = {}
end

function SELF:CreateMainButtonRow(height, noPage)
	local buttonRowData = {}
	buttonRowData.Height = height

	if isnumber(self.MaxListHeight) and not noPage then
		local currentPage = self.Pages[#self.Pages]

		local currentHeight = currentPage.Height or 0
		local newHeight = currentHeight + height

		local availableHeight = self.MaxListHeight - 2 * self.PageSelectorHeight
		if newHeight > availableHeight then -- New Page!
			newHeight = height

			currentPage = {}
			table.insert(self.Pages, currentPage)
		end

		currentPage.Rows = currentPage.Rows or {}
		table.insert(currentPage.Rows, buttonRowData)

		currentPage.Height = newHeight
	end

	table.insert(self.MainButtons, buttonRowData)
	buttonRowData.ColorOffset = table.Count(self.MainButtons) % 2

	buttonRowData.Buttons = {}

	return buttonRowData
end

function SELF:CreateSecondaryButtonRow(height)
	local buttonRowData = {}
	buttonRowData.Height = height

	table.insert(self.SecondaryButtons, buttonRowData)
	buttonRowData.ColorOffset = table.Count(self.SecondaryButtons) % 2

	buttonRowData.Buttons = {}

	return buttonRowData
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

function SELF:AddSelectorToRow(buttonRowData, name, values, defaultId, callback)
	if not istable(values) then return end

	function buttonRowData:SetValue(valueId)
		if valueId == 1 then
			buttonRowData.PrevButton.Disabled = true
		else
			buttonRowData.PrevButton.Disabled = false
		end
		if valueId == #values then
			buttonRowData.NextButton.Disabled = true
		else
			buttonRowData.NextButton.Disabled = false
		end

		local valueData = values[valueId]
		buttonRowData.ValueButton.Name = valueData.Name or "MISSING"
		buttonRowData.ValueButton.Data = valueData.Data
		buttonRowData.ValueButton.Color = valueData.Color or Star_Trek.LCARS.ColorOrange

		buttonRowData.Selected = valueId
	end
	function buttonRowData:SetDisabled(disabled)
		if disabled then
			buttonRowData.PrevButton.Disabled = true
			buttonRowData.NextButton.Disabled = true
		else
			local valueId = buttonRowData.Selected
			if valueId == 1 then
				buttonRowData.PrevButton.Disabled = true
			else
				buttonRowData.PrevButton.Disabled = false
			end
			if valueId == #values then
				buttonRowData.NextButton.Disabled = true
			else
				buttonRowData.NextButton.Disabled = false
			end
		end
	end

	buttonRowData.PrevButton = self:AddButtonToRow(buttonRowData, "<", nil, nil, nil, false, false, function(ply, buttonData)
		buttonRowData:SetValue(buttonRowData.Selected - 1)

		if isfunction(callback) then
			callback(ply, buttonData, values[buttonRowData.Selected])
		end
	end)

	self:AddButtonToRow(buttonRowData, name .. ":", nil, nil, nil, true)
	buttonRowData.ValueButton = self:AddButtonToRow(buttonRowData, "", nil, Star_Trek.LCARS.ColorOrange)

	buttonRowData.NextButton = self:AddButtonToRow(buttonRowData, ">"     , nil, nil, nil, false, false, function(ply, buttonData)
		buttonRowData:SetValue(buttonRowData.Selected + 1)

		if isfunction(callback) then
			callback(ply, buttonData, values[buttonRowData.Selected])
		end
	end)

	local defaultValueData = values[defaultId]
	if not istable(defaultValueData) then
		defaultId = 1
	end
	buttonRowData:SetValue(defaultId)
end

function SELF:AddPageSelectorToRow(buttonRowData)
	if not isnumber(self.MaxListHeight) then return end

	local values = {}
	for i, page in ipairs(self.Pages) do
		values[i] = {
			Name = tostring(i),
			Data = i
		}
	end

	self:AddSelectorToRow(buttonRowData, "Page", values, self.Page, function(ply, buttonData, value)
		local newPage = value.Data
		self.Page = newPage
	end)
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

function SELF:OnPress(interfaceData, ply, buttonId)
	local buttonData = self.Buttons[buttonId]
	if not istable(buttonData) then return end

	if buttonData.Disabled then return end

	if buttonData.Toggle then
		buttonData.Selected = not (buttonData.Selected or false)
	end

	local overrideSound = false
	if isfunction(buttonData.Callback) and buttonData.Callback(ply, buttonData) then
		overrideSound = true
	end

	if not overrideSound then
		interfaceData.Ent:EmitSound("star_trek.lcars_beep")
	end

	return true
end

function SELF:GetClientData()
	local clientData = SELF.Base.GetClientData(self)

	local mainButtons = self.MainButtons
	if isnumber(self.MaxListHeight) then
		local pagedMainButtons = {}

		local pageSelectorRow = {}
		pageSelectorRow.Height = self.PageSelectorHeight
		pageSelectorRow.Buttons = {}
		self:AddPageSelectorToRow(pageSelectorRow)

		table.insert(pagedMainButtons, pageSelectorRow)

		local currentPage = self.Pages[self.Page]
		for _, rowData in ipairs(currentPage.Rows) do
			table.insert(pagedMainButtons, rowData)
		end

		table.insert(pagedMainButtons, pageSelectorRow)

		mainButtons = pagedMainButtons
	end

	clientData.MainButtons = self:GetButtonClientData(mainButtons)
	clientData.SecondaryButtons = self:GetButtonClientData(self.SecondaryButtons)

	return clientData
end
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

	self.MainButtons = {}
	self.SecondaryButtons = {}
	self.MainButtonPages = {}
	self.PageNum = 1
	self.MaxListHeight = maxListHeight

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


function SELF:CreateMainButtonRow(height)

	local buttonRowData = {}
	buttonRowData.Height = height
	buttonList = self.MainButtons

	if self.MaxListHeight ~= nil then
		local flipRowData = {
			Height = 32,
			Buttons = {}
		}

		self:AddButtonToRow(flipRowData, "Previous", nil, Star_Trek.LCARS.ColorOrange, nil, false, false, function() end)
		local posButton = self:AddButtonToRow(flipRowData, "", nil, Star_Trek.LCARS.ColorOrangem, nil, true, false, function() end)
		posButton.ButtonId = 1000
		self:AddButtonToRow(flipRowData, "Next", nil, Star_Trek.LCARS.ColorOrange, nil, false, false, function() end)

		pages = self.MainButtonPages
		if #self.MainButtonPages == 0 then			--If there are no pages yet
			local firstPage = {}
			table.insert(firstPage, flipRowData)  -- Put the buttons at the top of the first page
			table.insert(firstPage, buttonRowData)
			table.insert(self.MainButtonPages, firstPage)
		else									--If pages already exist 
			stackedHeight = 0
			latestPage = self.MainButtonPages[#self.MainButtonPages]
			for _, rowData in pairs(latestPage) do
				stackedHeight = stackedHeight + rowData.Height
			end
			if stackedHeight >= self.MaxListHeight then  		-- If you cannot fit any more buttons on the page
				table.insert(latestPage, flipRowData)			-- These page turning buttons go at the very bottom of the last page before creating a new one.
				local newPage = {}								-- Create a new page and put the row in there instead
				table.insert(newPage, flipRowData)				-- Anotha page turning button. This time at the Top. Because we do this on creation, we don't need to cover that funk edge case we covered in the client data portion :)
				table.insert(newPage, buttonRowData)
				table.insert(self.MainButtonPages, newPage)		-- Make sure to actually register that new page
			else
				table.insert(latestPage, buttonRowData)			-- Otherwise there is no need to do anything special
			end

		end
	else
		table.insert(buttonList, buttonRowData)
	end
	buttonRowData.ColorOffset = table.Count(buttonList) % 2

	buttonRowData.Buttons = {}

	return buttonRowData
end

function SELF:CreateSecondaryButtonRow(height)

	buttonList = self.SecondaryButtons

	local buttonRowData = {}

	buttonRowData.Height = height

	table.insert(buttonList, buttonRowData)
	buttonRowData.ColorOffset = table.Count(buttonList) % 2

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

function SELF:GetButtonClientData(buttonList)
	local clientButtonList = {}

	if buttonList == self.MainButtons and #self.MainButtonPages ~= 0 then
		buttonList = self.MainButtonPages[self.PageNum]						-- Retrieve the currently selected page

		if not self:ContainsButton(buttonList) then -- There is a chance the last page doesn't get page flip buttons because it doesn't trigger the new page system created at the top of the file
			local buttonRowData = {}				-- Instead, we will just create it here, and do it only once by checking if the buttons happen to already exist
			buttonRowData.Height = 32
			buttonRowData.Buttons = {}

			self:AddButtonToRow(buttonRowData, "Previous", nil, Star_Trek.LCARS.ColorOrange, nil, false, false, function() end)
			local posButton = self:AddButtonToRow(buttonRowData, "", nil, Star_Trek.LCARS.ColorOrangem, nil, true, false, function() end)
			posButton.ButtonId = 1000

			self:AddButtonToRow(buttonRowData, "Next", nil, Star_Trek.LCARS.ColorOrange, nil, false, false, function() end)
			table.insert(buttonList, buttonRowData)

		end
	end

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

				if clientButtonData.ButtonId == 1000 then
					clientButtonData.Name = self.PageNum .. "/" .. #self.MainButtonPages	-- Dynamically update the display bar 
				end

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

	local name = buttonData.Name

	if self.MaxListHeight == nil then return true end

	if name == "Next" then
		self:TurnPageForwards()
	elseif name == "Previous" then
		self:TurnPageBackwards()
	end

	return true
end

function SELF:GetClientData()
	local clientData = SELF.Base.GetClientData(self)

	clientData.MainButtons = self:GetButtonClientData(self.MainButtons)
	clientData.SecondaryButtons = self:GetButtonClientData(self.SecondaryButtons)

	return clientData
end

function SELF:TurnPageForwards()
	local maxPages = #self.MainButtonPages
	if self.PageNum == maxPages then self.PageNum = 1
	else self.PageNum = self.PageNum + 1 end
	self:GetButtonClientData(self.MainButtonPages[self.PageNum])
end

function SELF:TurnPageBackwards()
	if self.PageNum == 1 then self.PageNum = #self.MainButtonPages
	else self.PageNum = self.PageNum - 1 end
	self:GetButtonClientData(self.MainButtonPages[self.PageNum])
end

function SELF:ContainsButton(buttonList)
	for _, row in pairs(buttonList) do
		for _, button in pairs(row.Buttons) do
			if button.Name == "Next" or button.Name == "Previous" then return true end
		end
	end
	return false
end
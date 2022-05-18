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
--    LCARS Button Matrix | Server   --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(mainButtons, title, titleShort, hFlip, secondaryButtons)
	local success = SELF.Base.OnCreate(self, title, titleShort, hFlip)
	if not success then
		return false
	end

	if not istable(buttons) then
		return false
	end

	self.MainButtons = {}
	self.SecondaryButtons = {}

	return true
end

function SELF:AddButton(secondary, name, color, activeColor, disabled, toggle, callback)
	local buttonData = {}

	local buttonList = self.MainButtons
	if secondary then
		buttonList = self.SecondaryButtons
	end

	buttonData.Name = name or "MISSING"

	if IsColor(color) then
		buttonData.Color = color
	else
		if table.Count(buttonList) % 2 then
			buttonData.Color = Star_Trek.LCARS.ColorLightBlue
		else
			buttonData.Color = Star_Trek.LCARS.ColorBlue
		end
	end

	buttonData.ActiveColor = activeColor or Star_Trek.LCARS.ColorOrange
	buttonData.Disabled = disabled

	buttonData.Toggle = toggle
	buttonData.Callback = callback


	table.insert(buttonList, buttonData)

	return buttonData
end

function SELF:AddMainButton(...)
	return self:AddButton(true, ...)
end

function SELF:AddSecondaryButton(...)
	return self:AddButton(true, ...)
end

--[[
function SELF:CreateButtons(buttons)
	local buttonTable = {}

	for _, button in pairs(buttons) do
		local buttonData = {
			Height = button.Height or 35,
			EndRow = button.EndRow or false,

			Toggle = button.Toggle or false,
		}

		table.insert(buttonTable, buttonData)
	end

	return buttonTable
end
]]

function SELF:GetClientData()
	local clientData = SELF.Base.GetClientData(self)

	clientData.ButtonHeight = self.ButtonHeight

	return clientData
end
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
--       LCARS Keypad | Server       --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:CreateKey(row, i)
	self:AddButtonToRow(row, tostring(i), nil, nil, nil, false, false, function()
		table.insert(self.Values, i)
	end)
end

function SELF:OnCreate(title, titleShort, hFlip)
	local success = SELF.Base.OnCreate(self, title, titleShort, hFlip)
	if not success then
		return false
	end

	self.Values = {}

	local row1 = self:CreateMainButtonRow(60)
	self:CreateKey(row1, 7)
	self:CreateKey(row1, 8)
	self:CreateKey(row1, 9)

	local row2 = self:CreateMainButtonRow(60)
	self:CreateKey(row2, 4)
	self:CreateKey(row2, 5)
	self:CreateKey(row2, 6)

	local row3 = self:CreateMainButtonRow(60)
	self:CreateKey(row3, 1)
	self:CreateKey(row3, 2)
	self:CreateKey(row3, 3)

	local row4 = self:CreateMainButtonRow(60)
	self:AddButtonToRow(row4, "Clear", nil, Star_Trek.LCARS.ColorRed, nil, false, false, function()
		self.Values = {}
	end)
	self:CreateKey(row4, 0)
	self:AddButtonToRow(row4, "Confirm", nil, Star_Trek.LCARS.ColorOrange, nil, false, false, function()
		return true
	end)

	return true
end

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	SELF.Base.OnPress(self, interfaceData, ply, buttonId)

	if buttonId ~= 12 then
		return
	end

	local values = self.Values
	self.Values = {}

	if isfunction(callback) and callback(self, interfaceData, ply, values) then
		return true
	end

	return false
end
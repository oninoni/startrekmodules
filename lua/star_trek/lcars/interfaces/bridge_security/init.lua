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
--   LCARS Bridge Security | Server  --
---------------------------------------

include("util.lua")

local SELF = INTERFACE
SELF.BaseInterface = "base"

-- Open a security Console
--
-- @param Entity ent
-- @return Boolean success
-- @return? Table windows
function SELF:Open(ent)
	local success2, menuWindow, actionWindow = self:CreateMenuWindow()
	if not success2 then
		return false, menuWindow
	end

	local success3, mapWindow = self:CreateMapWindow(1)
	if not success3 then
		return false, mapWindow
	end

	local success4, sectionWindow = Star_Trek.LCARS:CreateWindow(
		"category_list",
		Vector(-28, -5, -2),
		Angle(0, 0, 0),
		nil,
		500,
		700,
		function(windowData, interfaceData, categoryId, buttonId)
			if isnumber(buttonId) then
				local buttonData = windowData.Buttons[buttonId]

				mapWindow:SetSectionActive(buttonData.Data, buttonData.Selected)
				mapWindow:Update()
			else
				mapWindow:SetDeck(categoryId)
				mapWindow:Update()
			end
		end,
		Star_Trek.LCARS:GetSectionCategories(),
		"SECTIONS",
		"SECTNS",
		false,
		true
	)
	if not success4 then
		return false, menuWindow
	end

	local success5, textWindow = Star_Trek.LCARS:CreateWindow(
		"text_entry",
		Vector(0, -34, 8.2),
		Angle(0, 0, -90),
		24,
		500,
		290,
		function(windowData, interfaceData, categoryId, buttonId)
			return false
		end,
		Color(255, 255, 255),
		"Log File",
		"LOG",
		false
	)
	if not success5 then
		return false, textWindow
	end

	return true, {menuWindow, sectionWindow, mapWindow, actionWindow, textWindow}
end

-- Read out any Data, that can be retrieved externally.
--
-- @return? Table data
function SELF:GetData()
	local data = {}

	data.LogData = self.Windows[5].Lines
	data.LogTitle = "Security"

	return data
end

-- Wrap for use in Map.
function Star_Trek.LCARS:OpenSecurityMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "bridge_security")
end
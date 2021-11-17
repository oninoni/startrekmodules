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
--   LCARS Bridge Security | Server  --
---------------------------------------

include("util.lua")

local SELF = INTERFACE
SELF.BaseInterface = "base"

function SELF:OpenInternal(menuPos, menuAng, menuWidth, actionPos, actionAng, actionWidth, actionFlip, mapPos, mapAng, mapWidth, mapHeight, sectionPos, sectionAng, sectionWidth, sectionHeight, textPos, textAng, textWidth, textHeight)
	local success2, menuWindow, actionWindow = self:CreateMenuWindow(menuPos, menuAng, menuWidth, actionPos, actionAng, actionWidth, actionFlip)
	if not success2 then
		return false, menuWindow
	end

	local success3, mapWindow = self:CreateMapWindow(mapPos, mapAng, mapWidth, mapHeight, 1)
	if not success3 then
		return false, mapWindow
	end

	local success4, sectionWindow = Star_Trek.LCARS:CreateWindow(
		"category_list",
		sectionPos,
		sectionAng,
		nil,
		sectionWidth,
		sectionHeight,
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
		textPos,
		textAng,
		24,
		textWidth,
		textHeight,
		function(windowData, interfaceData, categoryId, buttonId)
			return false
		end,
		Color(255, 255, 255),
		"Log File",
		"LOG",
		true
	)
	if not success5 then
		return false, textWindow
	end

	return true, {menuWindow, sectionWindow, mapWindow, actionWindow, textWindow}
end

-- Open a security Console
--
-- @param Entity ent
-- @return Boolean success
-- @return? Table windows
function SELF:Open(ent, engineering)
	local success, windows = self:OpenInternal(
		Vector(-22, -34, 8.2),
		Angle(0, 0, -90),
		500,
		Vector(22, -34, 8.2),
		Angle(0, 0, -90),
		500,
		true,
		Vector(12.5, -2, -2),
		Angle(0, 0, 0),
		1100,
		680,
		Vector(-28, -5, -2),
		Angle(0, 0, 0),
		500,
		700,
		Vector(0, -34, 8.2),
		Angle(0, 0, -90),
		500,
		280
	)
	if not success then
		return false, windows
	end

	return true, windows, Vector(0, 11.5, -4), Angle(0, 0, -8)
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
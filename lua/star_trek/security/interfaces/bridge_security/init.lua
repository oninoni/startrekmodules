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
--   LCARS Bridge Security | Server  --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

include("util.lua")

SELF.BaseInterface = "base"

SELF.LogType = "Security Console"

function SELF:OpenInternal(menuPos, menuAng, menuWidth, actionPos, actionAng, actionWidth, actionFlip, mapPos, mapAng, mapScale, mapWidth, mapHeight, sectionPos, sectionAng, sectionWidth, sectionHeight, textPos, textAng, textScale, textWidth, textHeight)
	local success2, menuWindow, actionWindow = self:CreateMenuWindow(menuPos, menuAng, menuWidth, actionPos, actionAng, actionWidth, actionFlip)
	if not success2 then
		return false, menuWindow
	end

	local success3, mapWindow = self:CreateMapWindow(mapPos, mapAng, mapScale, mapWidth, mapHeight, 1)
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
		function(windowData, interfaceData, ply, categoryId, buttonId, buttonData)
			if isnumber(buttonId) then
				mapWindow:SetSectionActive(buttonData.Data, buttonData.Selected)
				mapWindow:Update()
			else
				mapWindow:SetDeck(categoryId)
				mapWindow:Update()
			end
		end,
		Star_Trek.Sections:GetSectionCategories(),
		"SECTIONS",
		"SECTNS",
		false,
		true
	)
	if not success4 then
		return false, sectionWindow
	end

	local success5, textWindow = Star_Trek.LCARS:CreateWindow(
		"log_entry",
		textPos,
		textAng,
		textScale,
		textWidth,
		textHeight,
		function(windowData, interfaceData, ply, categoryId, buttonId)
			return false
		end
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
function SELF:Open(ent)
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
		30,
		1600,
		1000,
		Vector(-28, -5, -2),
		Angle(0, 0, 0),
		500,
		700,
		Vector(0, -34, 8.2),
		Angle(0, 0, -90),
		24,
		500,
		280
	)
	if not success then
		return false, windows
	end

	return true, windows, Vector(0, 11.5, -4), Angle(0, 0, -8)
end

-- Wrap for use in Map.
function Star_Trek.LCARS:OpenSecurityMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "bridge_security")
end
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
function SELF:Open(ent)
	local success2, menuWindow, actionWindow = self:CreateMenuWindow()
	if not success2 then
		Star_Trek:Message(menuWindow)
		return
	end

	local success3, mapWindow = self:CreateMapWindow(1)
	if not success3 then
		Star_Trek:Message(mapWindow)
		return
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
		Star_Trek:Message(menuWindow)
		return
	end

	return {menuWindow, sectionWindow, mapWindow, actionWindow}
end

-- Wrap for use in Map.
function Star_Trek.LCARS:OpenSecurityMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "bridge_security")
end
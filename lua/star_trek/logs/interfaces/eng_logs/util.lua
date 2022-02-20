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
--    LCARS Bridge Security | Util   --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

function SELF:CreateControlMenu()
	local buttons = {
		[13] = {
			Name = "Disable Console",
			Color = Star_Trek.LCARS.ColorRed,
		}
	}

	local success, controlWindow = Star_Trek.LCARS:CreateWindow(
		"button_list",
		Vector(12, -2, -14.25),
		Angle(0, 0, 0),
		24,
		575,
		570,
		function(windowData, interfaceData, buttonId)
			if buttonId == 13 then
				windowData:Close()
				return
			end
		end,
		buttons,
		"Control",
		nil,
		true
	)
	if not success then
		return false, controlWindow
	end

	return true, controlWindow
end

function SELF:ApplyListWindowPage(categories, page)
	categories[5].Name = "Page " .. page
	if page == 1 then
		categories[1].Disabled = true
	else
		categories[1].Disabled = false
	end
end

function SELF:CreateListWindow(page)
	local categories = {
		{
			Name = "Previous Page",
			Buttons = {},
		},
		{
			Name = "01-02-2020",
			Disabled = true,
			Buttons = {},
		},
		{
			Name = "05-03-2020",
			Disabled = true,
			Buttons = {},
		},
		{
			Name = "Next Page",
			Buttons = {},
		},
		{
			Name = "Page X",
			Buttons = {},
		},
	}
	self:ApplyListWindowPage(categories, page)

	local success3, listWindow = Star_Trek.LCARS:CreateWindow(
		"category_list",
		Vector(-15, -26.25, 2.5),
		Angle(0, 0, -76.5),
		nil,
		600,
		600,
		function(windowData, interfaceData, categoryId, buttonId)
			if not buttonId then
				if categoryId == 1 then
					windowData.Page = math.max(1, windowData.Page - 1)
				elseif categoryId == 4 then
					windowData.Page = windowData.Page + 1
				end

				self:ApplyListWindowPage(windowData.Categories, windowData.Page)
				windowData.Selected = 5

				return
			end
		end,
		categories,
		"Logs",
		nil,
		false
	)
	if not success3 then
		return false, listWindow
	end

	listWindow.Page = 1
	listWindow.Selected = 5

	return true, listWindow
end
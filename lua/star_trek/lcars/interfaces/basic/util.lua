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
--    LCARS Basic Interface | Util   --
---------------------------------------

local SELF = INTERFACE

local colorTable = {
	red = 
}

-- Generate the buttons for a general purpose menu.
function SELF:GenerateButtons(keyValues)
	local buttons = {}
	for i = 1, 16 do
		local name = keyValues["lcars_name_" .. i]
		if isstring(name) then
			local disabled = tobool(keyValues["lcars_disabled_" .. i])
			local colorName = keyValues["lcars_color_" .. i] or ""

			buttons[i] = {
				Name = name,
				Disabled = disabled,
				Color = Star_Trek.LCARS.Colors[colorName]
			}
		else
			break
		end
	end

	return buttons
end

function SELF:GetKeyValues(keyValues, buttons)
	local scale = tonumber(keyValues["lcars_scale"]) or 20
	local width = tonumber(keyValues["lcars_width"]) or 16
	local height = tonumber(keyValues["lcars_height"])
	local title = keyValues["lcars_title"]
	local titleShort = keyValues["lcars_title_short"]
	if not titleShort then
		titleShort = ""
	end

	width = width * scale

	if not height then
		height = math.max(2, math.min(6, table.maxn(buttons))) * 35 + 80
	else
		height = height * scale
	end

	return scale, width, height, title, titleShort
end

function SELF:GetButtonData(ent)
	local keyValues = ent.LCARSKeyData
	if not istable(keyValues) then
		return false, "Invalid Key Values on OpenMenu"
	end

	local buttons = self:GenerateButtons(keyValues)
	local scale, width, height, title, titleShort = self:GetKeyValues(keyValues, buttons)

	return true, buttons, scale, width, height, title, titleShort
end
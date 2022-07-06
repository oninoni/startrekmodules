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
--    LCARS Basic Interface | Util   --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

-- Generate the buttons for a general purpose menu.
function SELF:GenerateButtons(keyValues)
	local buttons = {}

	for key, value in pairs(keyValues) do
		if not string.StartWith(key, "lcars_name_") then
			continue
		end
		if not isstring(value) then
			continue
		end

		local i = tonumber(string.sub(key, 12))
		if not isnumber(i) then
			continue
		end

		local disabled = tobool(keyValues["lcars_disabled_" .. i])
		local colorName = keyValues["lcars_color_" .. i] or ""

		buttons[i] = {
			Name = value,
			Disabled = disabled,
			Color = Star_Trek.LCARS.Colors[colorName]
		}
	end

	return buttons
end

function SELF:GetKeyValues(keyValues, buttons)
	local scale = tonumber(keyValues["lcars_scale"]) or 20
	local width = tonumber(keyValues["lcars_width"]) or 16
	local height = tonumber(keyValues["lcars_height"])
	local flip = tobool(keyValues["lcars_flip"]) or false
	local title = keyValues["lcars_title"]
	if isstring(title) then
		title = string.Replace(title, "@", " ")
	end

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

	return scale, width, height, title, titleShort, flip
end

function SELF:GetButtonData(ent)
	local keyValues = ent.LCARSKeyData
	if not istable(keyValues) then
		return false, "Invalid Key Values on OpenMenu"
	end

	local buttons = self:GenerateButtons(keyValues)
	local scale, width, height, title, titleShort, flip = self:GetKeyValues(keyValues, buttons)

	return true, buttons, scale, width, height, title, titleShort, flip
end
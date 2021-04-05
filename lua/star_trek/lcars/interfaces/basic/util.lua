local basicUtil = {}

-- Generate the buttons for a general purpose menu.
function basicUtil.GenerateButtons(keyValues)
	local buttons = {}
	for i = 1, 20 do
		local name = keyValues["lcars_name_" .. i]
		if isstring(name) then
			local disabled = keyValues["lcars_disabled_" .. i]

			buttons[i] = {
				Name = name,
				Disabled = disabled,
			}
		else
			break
		end
	end

	return buttons
end

function basicUtil.GetKeyValues(keyValues, buttons)
	local scale = tonumber(keyValues["lcars_scale"])
	local width = tonumber(keyValues["lcars_width"])
	local height = tonumber(keyValues["lcars_height"])
	local title = keyValues["lcars_title"]
	local titleShort = keyValues["lcars_title_short"]
	if titleShort == false then
		titleShort = ""
	end

	if not height then
		height = math.max(2, math.min(6, table.maxn(buttons))) * 35 + 80
	end

	return scale, width, height, title, titleShort
end

function basicUtil.GetButtonData(ent)
	local keyValues = ent.LCARSKeyData
	if not istable(keyValues) then
		return false, "Invalid Key Values on OpenMenu"
	end

	local buttons = basicUtil.GenerateButtons(keyValues)
	local scale, width, height, title, titleShort = basicUtil.GetKeyValues(keyValues, buttons)

	return true, buttons, scale, width, height, title, titleShort
end

return basicUtil
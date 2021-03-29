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

return basicUtil
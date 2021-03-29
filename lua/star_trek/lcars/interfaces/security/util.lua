local securityUtil = {}

-- Generates the map view.
function securityUtil.CreateMapWindow(deck)
	local success, mapWindow = Star_Trek.LCARS:CreateWindow("section_map", Vector(12.5, -2, -2), Angle(0, 0, 0), nil, 1100, 680, function(windowData, interfaceData, ent, buttonId)
		-- No Interactivity here yet.
	end, deck)
	if not success then
		return false, mapWindow
	end

	return true, mapWindow
end

return securityUtil
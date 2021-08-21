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
--           Alert | Client          --
---------------------------------------

-- Enable the given alert.
--
-- @param String alert
-- @return Boolean success
-- @return? String error
function Star_Trek.Alert:Enable(type)
	local alertType = self.AlertTypes[type]
	if not istable(alertType) then
		return false, "Invalid Alert"
	end

	local material = Material(Star_Trek.Alert.AlertMaterial)
	material:SetVector("$alarmcolor", Vector(
		alertType.Color.r / 256,
		alertType.Color.g / 256,
		alertType.Color.b / 256
	))

	return true
end

net.Receive("Star_Trek.Alert.Enable", function()
	Star_Trek.Alert:Enable(net.ReadString())
end)

-- Disable the current alert.
--
-- @return Boolean success
-- @return? String error
function Star_Trek.Alert:Disable()
	local material = Material(Star_Trek.Alert.AlertMaterial)
	material:SetVector("$alarmcolor", Vector(0, 0, 0))

	return true
end

net.Receive("Star_Trek.Alert.Disable", function()
	Star_Trek.Alert:Disable()
end)
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

hook.Add("Star_Trek.LCARS.PreWindowCreate", "Star_Trek.Alert.OverrideStyle", function(window, windowData)
	local type = Star_Trek.Alert.CurrentAlert
	if isstring(type) then
		local alertType = Star_Trek.Alert.AlertTypes[type]
		if not istable(alertType) then
			return
		end

		local style = alertType.LCARSStyle
		if isstring(style) then
			windowData.InitialStyle = style
		end
	end
end)

-- Enable the given alert.
--
-- @param String alert
-- @return Boolean success
-- @return? String error
function Star_Trek.Alert:Enable(type)
	if isstring(self.CurrentAlert) and self.CurrentAlert == type then
		return
	end

	local alertType = self.AlertTypes[type]
	if not istable(alertType) then
		return false, "Invalid Alert"
	end

	self.CurrentAlert = type

	local alertMaterial = Material(Star_Trek.Alert.AlertMaterial)
	alertMaterial:SetVector("$alarmcolor", Vector(
		alertType.Color.r / 256,
		alertType.Color.g / 256,
		alertType.Color.b / 256
	))

	local bridgeLightMaterial = Material(Star_Trek.Alert.BridgeLightMaterial)
	if alertType.BridgeDim then
		bridgeLightMaterial:SetFloat("$brightness", Star_Trek.Alert.BridgeDimAmmount)
	else
		bridgeLightMaterial:SetFloat("$brightness", 1)
	end

	local style = alertType.LCARSStyle
	if Star_Trek.Modules["lcars"] then
		if  isstring(style) then
			for _, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
				for _, window in pairs(interface.Windows) do
					window:SetStyle(style)
				end
			end
		else
			for _, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
				for _, window in pairs(interface.Windows) do
					window:SetStyle("LCARS")
				end
			end
		end
	end

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
	self.CurrentAlert = nil

	local material = Material(Star_Trek.Alert.AlertMaterial)
	material:SetVector("$alarmcolor", Vector(0, 0, 0))

	local bridgeLightMaterial = Material(Star_Trek.Alert.BridgeLightMaterial)
	bridgeLightMaterial:SetFloat("$brightness", 1)

	if Star_Trek.Modules["lcars"] then
		for _, interface in pairs(Star_Trek.LCARS.ActiveInterfaces) do
			for _, window in pairs(interface.Windows) do
				window:SetStyle("LCARS")
			end
		end
	end

	return true
end

net.Receive("Star_Trek.Alert.Disable", function()
	Star_Trek.Alert:Disable()
end)
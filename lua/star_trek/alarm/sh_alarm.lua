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
--           Alarm | Shared          --
---------------------------------------

function Star_Trek.Alarm:Register(type, onEnable, onDisable)
	local typeCapitalized = string.upper(string.sub(type, 1,1)) .. string.sub(type, 2)

	self["Enable" .. typeCapitalized .. "Alert"] = onEnable
	self["Disable" .. typeCapitalized .. "Alert"] = onDisable
end

Star_Trek.Alarm:Register("yellow", onEnable, onDisable)
Star_Trek.Alarm:Register("blue", onEnable, onDisable)
Star_Trek.Alarm:Register("red", onEnable, onDisable)
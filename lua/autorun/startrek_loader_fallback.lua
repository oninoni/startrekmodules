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
--         Star Trek | Loader        --
---------------------------------------

local detectMapStrings = {
	"rp_voyager",
	"rp_intrepid_v",
	"rp_intrepid_dev_v",
}
local skip = true
for _, mapString in pairs(detectMapStrings) do
	if string.StartWith(game.GetMap(), mapString) then
		skip = false
		continue
	end
end

if skip then return end

hook.Add("PostGamemodeLoaded", "Star_Trek.LoadBackup", function()
	timer.Simple(1, function()
		if istable(Star_Trek) then
			print("Hello Star Trek Lib!")
			print("This is rp_intrepid! Nice, too see we can work together again!")
		else
			Star_Trek = {}

			Star_Trek.LCARS = {}
			function Star_Trek.LCARS:OpenMenu() end
			function Star_Trek.LCARS:OpenSecurityMenu() end
			function Star_Trek.LCARS:OpenConsoleTransporterMenu() end
			function Star_Trek.LCARS:OpenTransporterEngMenu() end
			function Star_Trek.LCARS:OpenTransporterMenu() end
			function Star_Trek.LCARS:OpenSecurityEngMenu() end
			function Star_Trek.LCARS:OpenReplicatorMenu() end
			function Star_Trek.LCARS:OpenTurboliftMenu() end
			function Star_Trek.LCARS:OpenWallpanelMenu() end

			Star_Trek.Alert = {}
			function Star_Trek.Alert:Enable() end
			function Star_Trek.Alert:Disable() end

			Star_Trek.Security = {}
			function Star_Trek.Security:EnableNamedForceField() end
			function Star_Trek.Security:DisableNamedForceField() end

			Star_Trek.Util = {}
			function Star_Trek.Util:CompressPlayers() end
			function Star_Trek.Util:SetWarp() end
		end
	end)
end)
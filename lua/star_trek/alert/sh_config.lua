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
--           Alert | Config          --
---------------------------------------

Star_Trek.Alert.AlertMaterial = "models/kingpommes/startrek/intrepid/light_alarm"

Star_Trek.Alert.AlertTypes = {
	red = {
		Sound = "star_trek.red_alert",
		Color = Color(255, 0, 0),
	},
	yellow = {
		Sound = nil,
		Color = Color(255, 191, 0),
	},
	intruder = {
		Sound = "star_trek.blue_alert",
		Color = Color(255, 0, 0),
	},
	blue = {
		Sound = "star_trek.blue_alert",
		Color = Color(0, 0, 255),
	},
}

Star_Trek.Alert.OffFrame = 1
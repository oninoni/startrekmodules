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
--           Alert | Config          --
---------------------------------------

Star_Trek.Alert.AlertMaterial = "models/kingpommes/startrek/intrepid/light_alarm"

Star_Trek.Alert.AlertTypes = {
	red = {
		Sound = "star_trek.red_alert",
		Color = Color(255, 0, 0),
		BridgeDim = true,
		LCARSStyle = "LCARS_RED",
	},
	yellow = {
		Sound = nil,
		Color = Color(255, 191, 0),
		BridgeDim = false,
	},
	intruder = {
		Sound = "star_trek.blue_alert",
		Color = Color(255, 0, 0),
		BridgeDim = false,
	},
	blue = {
		Sound = "star_trek.blue_alert",
		Color = Color(0, 0, 255),
		BridgeDim = true,
	},
	abandon = {
		Sound = "star_trek.abandon_ship",
		Color = Color(255, 0, 0),
		BridgeDim = true,
	},
}

Star_Trek.Alert.OffFrame = 1

Star_Trek.Alert.BridgeLightMaterial = "models/kingpommes/startrek/intrepid/light_bridge_ceiling"

Star_Trek.Alert.BridgeDimName = "bridgeLights"

Star_Trek.Alert.BridgeDimAmmount = 0.8
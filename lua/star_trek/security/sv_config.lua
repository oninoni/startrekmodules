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
--         Security | Config         --
---------------------------------------

Star_Trek.Security.FrameModels = {
	["models/kingpommes/startrek/intrepid/panel_beam1.mdl"] = {
		Model = "models/kingpommes/startrek/intrepid/forcefield_hallway.mdl",
		Pos = Vector(4, 0, 0),
		Ang = Angle(0, 0, 0),
	},
	["models/kingpommes/startrek/intrepid/sickbay_op.mdl"] = {
		Model = "models/kingpommes/startrek/intrepid/forcefield_sickbay.mdl",
		Pos = Vector(0, 0, 0),
		Ang = Angle(0, 0, 0),
	},
	["models/kingpommes/startrek/intrepid/transporter_pad.mdl"] = {
		Model = "models/kingpommes/startrek/intrepid/forcefield_sickbay.mdl",
		Pos = Vector(0, 0, 0),
		Ang = Angle(0, -90, 0),
	},
	["models/kingpommes/startrek/intrepid/brig_fieldemitter.mdl"] = {
		Model = "models/kingpommes/startrek/intrepid/forcefield_brig.mdl",
		Pos = Vector(0, 0, 0),
		Ang = Angle(0, 0, 0),
	},
}

-- List all Door Models with their names.
Star_Trek.Security.DoorModelNames = {
	["models/kingpommes/startrek/intrepid/door_128a.mdl"]			= "Wide ?x128 A",
	["models/kingpommes/startrek/intrepid/door_128b.mdl"]			= "Wide ?x128 B",
	["models/kingpommes/startrek/intrepid/door_104.mdl"]			= "Door ?x104",
	["models/kingpommes/startrek/intrepid/door_80.mdl"]				= "Door ?x80",
	["models/kingpommes/startrek/intrepid/door_48.mdl"]				= "Door Normal",
	["models/kingpommes/startrek/intrepid/jef_doorhorizontal.mdl"]	= "Jeffries Hatch",
	["models/kingpommes/startrek/intrepid/jef_doorvertical.mdl"]	= "Jeffries Ladder Hatch",
}

Star_Trek.Security.DoorCloseDelay = 2

Star_Trek.Security.DoorThinkDelay = 0.2
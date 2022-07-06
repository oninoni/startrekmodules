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
--           Doors | Config          --
---------------------------------------

-- List all Door Models with their names.
Star_Trek.Doors.ModelNames = {
	["models/kingpommes/startrek/intrepid/door_128a.mdl"]			= "Wide ?x128 A",
	["models/kingpommes/startrek/intrepid/door_128b.mdl"]			= "Wide ?x128 B",
	["models/kingpommes/startrek/intrepid/door_128c.mdl"]			= "Wide ?x128 C",
	["models/kingpommes/startrek/intrepid/door_104.mdl"]			= "Door ?x104",
	["models/kingpommes/startrek/intrepid/door_80.mdl"]				= "Door ?x80",
	["models/kingpommes/startrek/intrepid/door_48.mdl"]				= "Door Normal",
	["models/kingpommes/startrek/intrepid/jef_doorhorizontal.mdl"]	= "Jeffries Hatch",
	["models/kingpommes/startrek/intrepid/jef_doorvertical.mdl"]	= "Jeffries Ladder Hatch",
}

-- Delay before a door closes.
Star_Trek.Doors.CloseDelay = 2

-- Interval in which a door checks, if it can close.
Star_Trek.Doors.ThinkDelay = 0.2

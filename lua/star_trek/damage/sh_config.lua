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
--          Damage | Config          --
---------------------------------------

Star_Trek.Damage.DamageTypes = {}

Star_Trek.Damage.DamageTypes["eps_breach"] = {
	Name = "EPS Conduit Breach",
	Entity = "plasma_conduit",
	StaticProps = {
		["models/kingpommes/startrek/intrepid/panel_wall48.mdl"] = {
			Locations = {
				{Pos = Vector( 8, -64, -10), Ang = Angle(0, 90, 0),},
			},
		},
		["models/kingpommes/startrek/intrepid/panel_wall56.mdl"] = {
			Locations = {
				{Pos = Vector(  0, -64, -10), Ang = Angle(0, 90, 0),},
			},
		},
		["models/kingpommes/startrek/intrepid/panel_wall128.mdl"] = {
			Locations = {
				{Pos = Vector(  0, -64, -10), Ang = Angle(0, 90, 0),},

				{Pos = Vector( 40, -64, -10), Ang = Angle(0, 90, 0),},
				{Pos = Vector(-40, -64, -10), Ang = Angle(0, 90, 0),},
			},
		},
	},
}
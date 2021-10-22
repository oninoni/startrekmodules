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
--        Replicator | Config        --
---------------------------------------

Star_Trek.Replicator.Categories = {
	{
		Name = "FOOD",
		Disabled = false,
		Buttons = {
			{
				Name = "Burger",
				Data = "models/food/burger.mdl",
			},
			{
				Name = "Wiener",
				Data = "models/food/hotdog.mdl",
			},
			{
				Name = "Soda",
				Data = "models/props_junk/PopCan01a.mdl",
			},
			{
				Name = "Tea Kettle",
				Data = "models/props_interiors/pot01a.mdl",
			},
			{
				Name = "Coffee",
				Data = "models/props_junk/garbage_coffeemug001a.mdl",
			},
			{
				Name = "Melon",
				Data = "models/props_junk/watermelon01.mdl",
			},
		},
	},
	{
		Name = "MEDICAL",
		Disabled = true,
		Buttons = {
			{
				Name = "Skull",
				Data = "models/Gibs/HGIBS.mdl",
			},
			{
				Name = "Healing Vial",
				Data = {
					Class = "item_healthvial",
				}
			}
		},
	},
	{
		Name = "WEAPONS",
		Disabled = true,
		Buttons = {
			{
				Name = "Antique Pistol",
				Data = {
					Class = "weapon_357"
				}
			}
		},
	},
	{
		Name = "MISC",
		Disabled = true,
		Buttons = {
			{
				Name = "Hula Doll",
				Data = "models/props_lab/huladoll.mdl",
			},
			{
				Name = "Cactus Plant",
				Data = "models/props_lab/cactus.mdl",
			}

		},
	},
}
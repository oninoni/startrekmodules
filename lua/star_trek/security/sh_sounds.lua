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
--       Doors Sounds | Shared       --
---------------------------------------

sound.Add({
	name = "star_trek.force_field_on",
	channel = CHAN_AUTO,
	volume = 1,
	level = 70,
	pitch = {95, 105},
	sound = "oninoni/startrek/force_field/force_field_on_boosted.wav",
})

sound.Add({
	name = "star_trek.force_field_off",
	channel = CHAN_AUTO,
	volume = 1,
	level = 70,
	pitch = {95, 105},
	sound = "oninoni/startrek/force_field/force_field_off_boosted.wav",
})

sound.Add({
	name = "star_trek.force_field_touch",
	channel = CHAN_AUTO,
	volume = 1,
	level = 70,
	pitch = 100,
	sound = "oninoni/startrek/force_field/force_field_touch_boosted.wav",
})

sound.Add({
	name = "star_trek.force_field_touch2",
	channel = CHAN_AUTO,
	volume = 1,
	level = 70,
	pitch = 100,
	sound = "oninoni/startrek/force_field/force_field_touch2_boosted.wav",
})

sound.Add({
	name = "star_trek.force_field_loop",
	channel = CHAN_AUTO,
	volume = 0.5,
	level = 50,
	pitch = 80,
	sound = "ambient/energy/force_field_loop1.wav",
})
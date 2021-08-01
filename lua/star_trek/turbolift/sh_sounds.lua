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
--     Turbolift Sounds | Shared     --
---------------------------------------

sound.Add({
	name = "star_trek.turbolift_start",
	channel = CHAN_USER_BASE + 1,
	volume = 1,
	level = 100,
	pitch = 100,
	sound = "oninoni/startrek/turbolift/tng_turbolift_movestart_loop.wav",
})

sound.Add({
	name = "star_trek.turbolift_stop",
	channel = CHAN_USER_BASE + 1,
	volume = 1,
	level = 70,
	pitch = 100,
	sound = "oninoni/startrek/turbolift/tng_turbolift_movestop_clean.wav",
})
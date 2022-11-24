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
--     Federation Cycle | Shared     --
---------------------------------------

if not istable(CYCLE) then Star_Trek:LoadAllModules() return end
local SELF = CYCLE

-- Determines the parent transport cycles name for this one. (Like Deriving Classes)
SELF.BaseCycle = "base"

SELF.BufferColor = Color(63, 255, 63)

-- Data of the states being processed.
SELF.States = {
	[1] = { -- Demat
		Duration = 3,

		CollisionGroup = COLLISION_GROUP_DEBRIS,
		RenderMode = RENDERMODE_TRANSTEXTURE,

		EnableMovement = false,
		Shadow = false,

		SoundName = "star_trek.borg_transporter",

		ParticleName = "beam_out_green",
		ColorTint = Color(63, 255, 63),
		ColorFade = 1,
	},
	[2] = { -- Demat Done (Buffer)
		Duration = 2,

		RenderMode = RENDERMODE_TRANSTEXTURE,

		TPToBuffer = true,
		ColorFade = 0,
	},
	[3] = { -- Remat
		Duration = 3,

		RenderMode = RENDERMODE_TRANSTEXTURE,

		SoundName = "star_trek.borg_transporter",
		PlaySoundAtTarget = true,

		TPToTarget = true,

		ParticleName = "beam_in_green",
		ColorTint = Color(0, 255, 63),
		ColorFade = -1,
	},
	[4] = { -- Cleanup (Variable Reset happen automatically)
		Duration = 0,
	}
}
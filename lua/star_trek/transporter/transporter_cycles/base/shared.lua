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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--  Base Transporter Cycle | Shared  --
---------------------------------------

if not istable(CYCLE) then Star_Trek:LoadAllModules() return end
local SELF = CYCLE

if SERVER then
	AddCSLuaFile("modules/render_mode.lua")
	AddCSLuaFile("modules/color.lua")
	AddCSLuaFile("modules/particles.lua")

	include("modules/collision_group.lua")
	include("modules/render_mode.lua")
	include("modules/color.lua")
	include("modules/movement.lua")
end

if CLIENT then
	include("modules/render_mode.lua")
	include("modules/color.lua")
	include("modules/particles.lua")
end

-- Determines the parent transport cycles name for this one. (Like Deriving Classes)
SELF.BaseCycle = nil

-- Data of the states being processed.
SELF.States = {
	[1] = { -- Demat
		Duration = 2,

		CollisionGroup = COLLISION_GROUP_DEBRIS,
		RenderMode = RENDERMODE_TRANSTEXTURE,

		EnableMovement = false,
		Shadow = false,

		SoundName = "star_trek.voy_beam_up",

		ParticleName = "beam_out",
		ColorFade = 1,
	},
	[2] = { -- Demat Done (Buffer)
		Duration = 1,

		RenderMode = RENDERMODE_TRANSTEXTURE,

		TPToBuffer = true,
	},
	[3] = { -- Remat
		Duration = 2,

		RenderMode = RENDERMODE_TRANSTEXTURE,

		SoundName = "star_trek.voy_beam_down",

		TPToTarget = true,

		ParticleName = "beam_in",
		ColorFade = -1,
	},
	[4] = { -- Cleanup (Variable Reset happen automatically)
		Duration = 0,
	}
}

-- Cycle Start / End ID's for skipping Demat or Remat.
SELF.SkipDematState = 3
SELF.SkipRematState = 2

function SELF:GetStateData()
	local state = self.State
	local stateData = self.States[state]

	return stateData or false
end
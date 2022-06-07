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
--      LCARS Turbolift | Server     --
---------------------------------------

include("util.lua")

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = "base"

SELF.LogType = false

SELF.Solid = true

-- Opening a turbolift control menu.
function SELF:Open(ent)
	local keyValues = ent.LCARSKeyData
	if istable(keyValues) then
		name = keyValues["lcars_name"]
	end

	local overrideName = hook.Run("Star_Trek.Turbolift.OverrideName", ent)
	if isstring(overrideName) then
		name = overrideName
	end

	local success, window = Star_Trek.LCARS:CreateWindow(
		"button_list",
		Vector(),
		Angle(),
		30,
		500,
		400,
		function(windowData, interfaceData, ply, buttonId)
			if ent.IsTurbolift then
				local canStart = Star_Trek.Turbolift:StartLift(ply, ent, buttonId)
				if canStart then
					ent:EmitSound("star_trek.lcars_close")
					Star_Trek.LCARS:CloseInterface(ent)
				else
					sourceLift:EmitSound("star_trek.lcars_error")
				end
			elseif ent.IsPod then
				if buttonId == 1 then
					if Star_Trek.Turbolift:TogglePos(ply, ent) then
						windowData.Buttons[1].Name = "Resume Lift"
					else
						windowData.Buttons[1].Name = "Stop Lift"
					end

					return true
				else
					Star_Trek.Turbolift:ReRoutePod(ply, ent, buttonId - 1)

					ent:EmitSound("star_trek.lcars_close")
					Star_Trek.LCARS:CloseInterface(ent)
				end
			end
		end,
		self:GenerateButtons(ent, name),
		"TURBOLIFT",
		"LIFT"
	)
	if not success then
		return false, window
	end

	return true, {window}
end

-- Wrap for use in Map.
function Star_Trek.LCARS:OpenTurboliftMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "turbolift")
end
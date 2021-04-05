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
--      LCARS Turbolift | Server     --
---------------------------------------

local turboliftUtil = include("util.lua")

-- Opening a turbolift control menu.
function Star_Trek.LCARS:OpenTurboliftMenu()
	local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
	if not success then
		-- Error Message
		Star_Trek:Message(ent)
		return
	end

	if istable(self.ActiveInterfaces[ent]) then
		return
	end

	local keyValues = ent.LCARSKeyData
	if not istable(keyValues) then
		Star_Trek:Message("Invalid Key Values on OpenTLMenu")
		return
	end

	local buttons = turboliftUtil.GenerateButtons(ent, keyValues)

	local success2, window = self:CreateWindow(
		"button_list",
		Vector(),
		Angle(),
		30,
		600,
		325,
		function(windowData, interfaceData, buttonId)
			if ent.IsTurbolift then
				Star_Trek.Turbolift:StartLift(ent, buttonId)

				ent:EmitSound("star_trek.lcars_close")
				Star_Trek.LCARS:CloseInterface(ent)
			elseif ent.IsPod then
				if buttonId == 1 then
					if Star_Trek.Turbolift:TogglePos(ent) then
						windowData.Buttons[1].Name = "Resume Lift"
					else
						windowData.Buttons[1].Name = "Stop Lift"
					end

					return true
				else
					Star_Trek.Turbolift:ReRoutePod(ent, buttonId - 1)

					ent:EmitSound("star_trek.lcars_close")
					Star_Trek.LCARS:CloseInterface(ent)
				end
			end
		end,
		buttons,
		"TURBOLIFT",
		"TRBLFT"
	)
	if not success2 then
		Star_Trek:Message(window)
		return
	end

	local success3, error = self:OpenInterface(ent, window)
	if not success3 then
		Star_Trek:Message(error)
		return
	end
end
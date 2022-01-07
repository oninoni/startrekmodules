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
--   LCARS Basic Interface | Server  --
---------------------------------------

include("util.lua")

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = "base"

-- Opening general purpose menus.
function SELF:Open(ent)
	local success2, buttons, scale, width, height, title, titleShort, flip = self:GetButtonData(ent)
	if not success2 then
		return false, buttons
	end

	local success3, window = Star_Trek.LCARS:CreateWindow(
		"button_list",
		Vector(),
		Angle(),
		scale,
		width,
		height,
		function(windowData, interfaceData, buttonId)
			local keyValues = ent.LCARSKeyData

			if buttonId <= 4 then
				ent:Fire("FireUser" .. buttonId)
			end

			if istable(keyValues) and isstring(keyValues["lcars_linked_case"]) then
				for _, caseEnt in pairs(ents.FindByName(keyValues["lcars_linked_case"])) do
					if IsValid(caseEnt) then
						caseEnt:Fire("InValue", buttonId)
					end
				end
			end

			if istable(keyValues) and keyValues["lcars_keep_open"] then
				ent:EmitSound("star_trek.lcars_beep")

				return
			end

			hook.Run("Star_Trek.LCARS.BasicPressed", interfaceData, buttonId)

			ent:EmitSound("star_trek.lcars_close")
			interfaceData:Close()
		end,
		buttons,
		title,
		titleShort, not flip
	)
	if not success3 then
		return false, window
	end

	return true, {window}
end

-- Detect updates in "lcars_name_i", "lcars_disabled_i".
hook.Add("Star_Trek.ChangedKeyValue", "Star_Trek.LCARS.BasicInterface", function(ent, key, value)
	if string.StartWith(key, "lcars_name_") or string.StartWith(key, "lcars_disabled_") or string.StartWith(key, "lcars_color_") then
		local keyValues = ent.LCARSKeyData
		if istable(keyValues) then
			local interfaceData = Star_Trek.LCARS.ActiveInterfaces[ent]
			if istable(interfaceData) then
				interfaceData.Windows[1]:SetButtons(interfaceData:GenerateButtons(ent.LCARSKeyData))
				interfaceData:UpdateWindow(1)
			end
		end
	end
end)

-- Wrap for use in Map.
function Star_Trek.LCARS:OpenMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "basic")
end
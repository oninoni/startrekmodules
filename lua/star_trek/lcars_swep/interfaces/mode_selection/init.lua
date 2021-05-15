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
--   LCARS Tricorder Modes | Server  --
---------------------------------------

local SELF = INTERFACE
SELF.BaseInterface = "base"

function SELF:Open(ent, modes)
	local buttons = {}

	for _, mode in pairs(modes) do

		table.insert(buttons, {
			Name = "Close",
			Disabled = false, -- TODO: Maybe disable if not applicable?
		})
	end

	table.insert(buttons, {
		Name = "Close",
	})

	local owner = ent:GetOwner()
	Star_Trek.LCARS:EnableScreenClicker(owner, true)

	local success, window = Star_Trek.LCARS:CreateWindow(
		"button_list",
		Vector(),
		Angle(),
		50,
		300,
		400,
		function(windowData, interfaceData, buttonId)
			if buttonId == table.Count(modes) + 1 then
				interfaceData:Close()

				Star_Trek.LCARS:EnableScreenClicker(owner, false)
			else
				print(buttonId)
			end
		end,
		buttons,
		"Tricorder Modes",
		"MODES"
	)
	if not success then
		return false, window
	end

	return true, {window}
end
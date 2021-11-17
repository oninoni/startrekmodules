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
--     LCARS Wall Panel | Server     --
---------------------------------------

local SELF = INTERFACE
SELF.BaseInterface = "base"

local buttons = {
	[1] = {
		Name = "Display Data",
	},
	[2] = {
		Name = "Forcefields",
		Disabled = true,
	},
	[3] = {
		Name = "Communicator",
		Disabled = true,
	},
	[13] = {
		Name = "Close",
		Color = Star_Trek.LCARS.ColorRed,
	},
}

function SELF:Open(ent)
	local keyValues = ent.LCARSKeyData

	local scale = 15

	local size = keyValues["lcars_panelsize"]

	local w = 31
	local h = 36
	local x = -size / 2 + 16
	local success, window = Star_Trek.LCARS:CreateWindow(
		"button_list",
		Vector(x, 0, 0),
		Angle(),
		scale,
		w * scale,
		h * scale,
		function(windowData, interfaceData, buttonId)
			if buttonId == 13 then
				ent:EmitSound("star_trek.lcars_close")
				interfaceData:Close()

				return
			end
		end,
		buttons,
		"Select Mode",
		"MODE",
		true
	)
	if not success then
		return false, window
	end

	local w2 = size - w - 2
	local success2, mainWindow = Star_Trek.LCARS:CreateWindow(
		"text_entry",
		Vector((size - w2) / 2 - 1, 0, 0),
		Angle(),
		scale,
		w2 * scale,
		(h - 2) * scale,
		function(windowData, interfaceData, buttonId)
		end,
		buttons,
		"Logs",
		"LOGS"
	)
	if not success2 then
		return false, mainWindow
	end

	return true, {window, mainWindow}, Vector(0, 0.3, -0.8)
end

-- Read out any Data, that can be retrieved externally.
--
-- @return? Table data
function SELF:GetData()
	local data = {}

	local window = self.Windows[2]
	data.LogData = window.Lines
	data.LogTitle = window.Title

	return data
end

function SELF:SetData(logType, lines)
	local window = self.Windows[1]
	window.Title = logType
	window.Lines = lines

	window:Update()
end

-- Wrap for use in Map.
function Star_Trek.LCARS:OpenWallpanelMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "wallpanel")
end
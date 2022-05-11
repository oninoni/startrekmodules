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
--   LCARS Targeting Int. | Server   --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = "base"

-- Opening general purpose menus.
function SELF:Open(ent, flipped)
	self.Flipped = flipped

	local mapWindowPos = Vector(-45, -10, 30)
	local mapWindowAng = Angle(0, 70, 90)
	local targetInfoWindowPos = Vector(-45.6, -20, 3.6)
	local targetInfoWindowAng = Angle(0, 71.5, 27)
	local targetSelectionWindowPos = Vector(-26, -1, 3.5)
	local targetSelectionWindowAng = Angle(0, 0, 11)
	local shipInfoWindowPos = Vector(-27.25, -4.3, 2.8)
	local shipInfoWindowAng = Angle(0, 0, 11)
	if self.Flipped then
		mapWindowPos = Vector(45, -10, 30)
		mapWindowAng = Angle(0, -70, 90)
		targetInfoWindowPos = Vector(45.6, -20, 3.6)
		targetInfoWindowAng = Angle(0, -71.5, 27)
		targetSelectionWindowPos = Vector(26, -1, 3.5)
		--targetSelectionWindowAng = Angle(0, 0, 11)
		shipInfoWindowPos = Vector(27.25, -4.3, 2.8)
		--shipInfoWindowAng = Angle(0, 0, 11)
	end

	local success1, mapWindow = Star_Trek.LCARS:CreateWindow("system_map", mapWindowPos, mapWindowAng, 15, 600, 600,
	function(windowData, interfaceData, ply, buttonId)
		-- No Interactivity here yet.
	end, systemName, not self.Flipped)
	if not success1 then
		return false, mapWindow
	end

	local success2, targetInfoWindow = Star_Trek.LCARS:CreateWindow("target_info", targetInfoWindowPos, targetInfoWindowAng, nil, 420, 140,
	function(windowData, interfaceData, ply, buttonId)
		-- No Interactivity here yet.
	end, 1, false, self.Flipped)
	if not success2 then
		return false, targetInfoWindow
	end

	local buttons = {
		[1] = {
			Name = "Lock Tractor Beam",
			Disabled = true,
		},
		[5] = {
			Name = "Close Menu",
			Color = Star_Trek.LCARS.ColorRed
		},
	}

	local categories = {
		{
			Name = "Previous Target",
			Buttons = buttons
		},
		{
			Name = "Next Target",
			Buttons = buttons
		},
		{
			Name = "De-Select Target",
			Buttons = buttons
		},
	}

	local success3, targetSelectionWindow = Star_Trek.LCARS:CreateWindow("category_list", targetSelectionWindowPos, targetSelectionWindowAng, nil, 360, 350,
	function(windowData, interfaceData, ply, categoryId, buttonId)
		if buttonId == 5 then
			interfaceData:Close()
		end

		-- No Interactivity here yet.
	end, categories, "Target Selection", "TARGET", not self.Flipped)
	if not success3 then
		return false, mapWindow
	end

	local success4, shipInfoWindow = Star_Trek.LCARS:CreateWindow("ship_info", shipInfoWindowPos, shipInfoWindowAng, 22, 340, 120,
	function(windowData, interfaceData, ply, buttonId)
		-- No Interactivity here yet.
	end, self.Flipped)
	if not success4 then
		return false, targetInfoWindow
	end

	return true, {mapWindow, targetInfoWindow, targetSelectionWindow, shipInfoWindow}, Vector(), Angle(0, 90, 0)
end
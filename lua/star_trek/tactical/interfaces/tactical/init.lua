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
-- LCARS Tactical Interface | Server --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = "bridge_targeting_base"

-- Opening general purpose menus.
function SELF:Open(ent)
	local success, windows, offsetPos, offsetAngle = SELF.Base.Open(self, ent, true)

	local shieldSelectionWindowPos = Vector(0, -1.5, 3.3)
	local shieldSelectionWindowAng = Angle(0, 0, 11)

	local success2, shieldWindow = Star_Trek.LCARS:CreateWindow("button_matrix", shieldSelectionWindowPos, shieldSelectionWindowAng, nil, 380, 320,
	function(windowData, interfaceData, ply, categoryId, buttonId)
		-- No Interactivity here yet.
	end, "Shield Control", "PHASER", not self.Flipped)
	if not success2 then
		return false, mapWindow
	end

	local shieldChargeRow = shieldWindow:CreateSecondaryButtonRow(32)
	shieldWindow:AddButtonToRow(shieldChargeRow, "Enable Shields", nil, Star_Trek.LCARS.ColorOrange, activeColor, disabled, toggle, callback)

	local shieldFreqRow = shieldWindow:CreateSecondaryButtonRow(32)
	shieldWindow:AddButtonToRow(shieldFreqRow, "<"         , nil, color, activeColor, false, false, callback)
	shieldWindow:AddButtonToRow(shieldFreqRow, "Frequency:", nil, color, activeColor, false, false, callback)
	shieldWindow:AddButtonToRow(shieldFreqRow, "1 GHz"     , nil, color, activeColor, false, false, callback)
	shieldWindow:AddButtonToRow(shieldFreqRow, ">"         , nil, color, activeColor, false, false, callback)

	table.insert(windows, shieldWindow)

	local weaponSelectionWindowPos = Vector(-26, -1, 3.5)
	local weaponSelectionWindowAng = Angle(0, 0, 11)

	local success3, weaponWindow = Star_Trek.LCARS:CreateWindow("button_matrix", weaponSelectionWindowPos, weaponSelectionWindowAng, nil, 360, 350,
	function(windowData, interfaceData, ply, categoryId, buttonId)
		-- No Interactivity here yet.
	end, "Weapons Control", "WEAPON", self.Flipped)
	if not success3 then
		return false, mapWindow
	end

	-- Phaser Control
	local phaserChargeRow = weaponWindow:CreateSecondaryButtonRow(32)
	weaponWindow:AddButtonToRow(phaserChargeRow, "Charge Phasers", nil, Star_Trek.LCARS.ColorOrange, activeColor, disabled, toggle, callback)

	local pasherPowerRow = weaponWindow:CreateSecondaryButtonRow(32)
	weaponWindow:AddButtonToRow(pasherPowerRow, "<"     , nil, color, activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(pasherPowerRow, "Yield:", nil, color, activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(pasherPowerRow, "100%"  , nil, color, activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(pasherPowerRow, ">"     , nil, color, activeColor, false, false, callback)

	local phaserFreqRow = weaponWindow:CreateSecondaryButtonRow(32)
	weaponWindow:AddButtonToRow(phaserFreqRow, "<"         , nil, color, activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(phaserFreqRow, "Frequency:", nil, color, activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(phaserFreqRow, "1 GHz"     , nil, color, activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(phaserFreqRow, ">"         , nil, color, activeColor, false, false, callback)

	local phaserFireRow = weaponWindow:CreateSecondaryButtonRow(32)
	weaponWindow:AddButtonToRow(phaserFireRow, "Fire Burst"  , nil, Star_Trek.LCARS.ColorRed   , activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(phaserFireRow, "Fire at Will", nil, Star_Trek.LCARS.ColorOrange, activeColor, false, false, callback)

	-- Torpedo Control
	local torpedoChargeRow = weaponWindow:CreateMainButtonRow(32)
	weaponWindow:AddButtonToRow(torpedoChargeRow, "Prime Torpedos", nil, Star_Trek.LCARS.ColorOrange, activeColor, disabled, toggle, callback)

	local torpedoPowerRow = weaponWindow:CreateMainButtonRow(32)
	weaponWindow:AddButtonToRow(torpedoPowerRow, "<"     , nil, color, activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(torpedoPowerRow, "Yield:", nil, color, activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(torpedoPowerRow, "100%"  , nil, color, activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(torpedoPowerRow, ">"     , nil, color, activeColor, false, false, callback)

	local torpedoTypeRow = weaponWindow:CreateMainButtonRow(32)
	weaponWindow:AddButtonToRow(torpedoTypeRow, "<"     , nil, color, activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(torpedoTypeRow, "Type:" , nil, color, activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(torpedoTypeRow, "Photon", nil, color, activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(torpedoTypeRow, ">"     , nil, color, activeColor, false, false, callback)

	local torpedoFireRow = weaponWindow:CreateMainButtonRow(32)
	weaponWindow:AddButtonToRow(torpedoFireRow, "Fire Single", nil, Star_Trek.LCARS.ColorOrange, activeColor, false, false, callback)
	weaponWindow:AddButtonToRow(torpedoFireRow, "Fire Burst" , nil, Star_Trek.LCARS.ColorRed   , activeColor, false, false, callback)

	table.insert(windows, weaponWindow)

	return success, windows, offsetPos, offsetAngle
end
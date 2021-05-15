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
--      LCARS Base SWEP | Server     --
---------------------------------------

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end

	local interfaceData = Star_Trek.LCARS.ActiveInterfaces[self]
	if istable(interfaceData) and interfaceData.InterfaceName == "mode_selection" then return end

	Star_Trek.LCARS:CloseInterface(self, function()
		Star_Trek.LCARS:OpenInterface(self:GetOwner(), self, "mode_selection", {})
	end)
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
end
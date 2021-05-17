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

function SWEP:Initialize()
	self.ActiveMode = false
end

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end

	self.ActiveMode = false

	local interfaceData = Star_Trek.LCARS.ActiveInterfaces[self]
	if istable(interfaceData) and interfaceData.InterfaceName == "mode_selection" then return end

	Star_Trek.LCARS:CloseInterface(self, function()
		self:DeactivateMode()

		Star_Trek.LCARS:OpenInterface(self:GetOwner(), self, "mode_selection", self.Modes)
	end)
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if not self.ActiveMode then return end
	if not isfunction(self.ActiveMode.PrimaryAttack) then return end

	self.ActiveMode:PrimaryAttack(self)
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	if not self.ActiveMode then return end
	if not isfunction(self.ActiveMode.SecondaryAttack) then return end

	self.ActiveMode:SecondaryAttack(self)
end

function SWEP:DeactivateMode()
	if istable(self.ActiveMode) then
		self.ActiveMode:Deactivate(self)
		self.ActiveMode = false
	end
end

function SWEP:ActivateMode(modeName)
	self:DeactivateMode()

	self.ActiveMode = Star_Trek.LCARS_SWEP.Modes[modeName]
	if istable(self.ActiveMode) then
		self.ActiveMode:Activate(self)
	end
end

util.AddNetworkString("Star_Trek.LCARS_SWEP.EnableScreenClicker")
function SWEP:EnableScreenClicker(enabled)
	local ply = self:GetOwner()

	net.Start("Star_Trek.LCARS_SWEP.EnableScreenClicker")
		net.WriteEntity(self)
		net.WriteBool(enabled)
	net.Send(ply)
end
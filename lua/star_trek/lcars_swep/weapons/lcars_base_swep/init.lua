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
--      LCARS Base SWEP | Server     --
---------------------------------------

function SWEP:InitializeCustom()
	self.ActiveMode = false
	self.ModeCache = {}
end

function SWEP:Deploy()
	if self.DefaultMode then
		timer.Simple(0, function()
			self:ActivateMode(self.DefaultMode)
		end)
	end
end

function SWEP:OnDrop()
	--if self.ActiveMode then
	--	self:DeactivateMode()
	--end
end

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end

	local interfaceData = Star_Trek.LCARS.ActiveInterfaces[self]
	if istable(interfaceData) and interfaceData.InterfaceName == "mode_selection" then return end

	if self.ActiveMode then
		self:DeactivateMode(function()
			Star_Trek.LCARS:OpenInterface(self:GetOwner(), self, "mode_selection", self.Modes)
		end)
	else
		Star_Trek.LCARS:CloseInterface(self, function()
			Star_Trek.LCARS:OpenInterface(self:GetOwner(), self, "mode_selection", self.Modes)
		end)
	end
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

function SWEP:ActivateMode(modeName)
	self:DeactivateMode(function()
		local mode = {}
		if istable(self.ModeCache[modeName]) then
			mode = self.ModeCache[modeName]
		else
			local modeFunctions = Star_Trek.LCARS_SWEP.Modes[modeName]
			if istable(modeFunctions) then
				setmetatable(mode, {__index = modeFunctions})
				self.ModeCache[modeName] = mode
			else
				return
			end
		end

		mode:Activate(self) -- TODO Process the Return Values

		self.ActiveMode = mode
	end)
end

function SWEP:DeactivateMode(callback)
	if istable(self.ActiveMode) then
		self.ActiveMode:Deactivate(self, callback) -- TODO Process the Return Values
		self.ActiveMode = false

		return
	end

	callback()
end

util.AddNetworkString("Star_Trek.LCARS_SWEP.EnableScreenClicker")
function SWEP:EnableScreenClicker(enabled)
	local ply = self:GetOwner()

	self.ScreenClickerEnabled = enabled

	net.Start("Star_Trek.LCARS_SWEP.EnableScreenClicker")
		net.WriteEntity(self)
		net.WriteBool(enabled)
	net.Send(ply)
end
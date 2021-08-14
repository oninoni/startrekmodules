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
--      LCARS Base SWEP | Client     --
---------------------------------------

SWEP.Category = "Star Trek"

SWEP.DrawAmmo = false

function SWEP:GetPosAngle()
	local owner = self:GetOwner()
	if not IsValid(owner) then
		return
	end
	if owner ~= LocalPlayer() then
		return
	end

	local vm = owner:GetViewModel()
	if not IsValid(vm) then
		return
	end

	local m = vm:GetBoneMatrix(vm:LookupBone(self.CustomViewModelBone))
	local oPos, oAng = LocalToWorld(self.CustomViewModelOffset, self.CustomViewModelAngle, m:GetTranslation(), m:GetAngles())
	oPos, oAng = LocalToWorld(self.MenuOffset, self.MenuAngle, oPos, oAng)

	return oPos, oAng
end

function SWEP:DrawWindow()
	local interface = Star_Trek.LCARS.ActiveInterfaces[self.InterfaceId]
	if istable(interface) then
		interface.IVis = true

		render.SuppressEngineLighting(true)

		local iPos, iAng = self:GetPosAngle()
		for _, window in pairs(interface.Windows) do
			window.WPosG, window.WAngG = LocalToWorld(window.WPos, window.WAng, iPos, iAng)
			window.WVis = true

			Star_Trek.LCARS:DrawWindow(window, interface.AnimPos, (not interface.Closing) and IsValid(self.Panel))
		end

		surface.SetAlphaMultiplier(1)
		render.SuppressEngineLighting(false)
	end
end

function SWEP:DrawViewModelCustom(flags)
	self:DrawWindow()
end
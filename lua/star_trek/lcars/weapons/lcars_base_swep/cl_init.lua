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

hook.Add("Star_Trek.LCARS.OverridePosAng", "Star_Trek.LCARS.OverrideSWEPViewmodel", function(ent, pos, ang)
	if not ent.IsLCARS then return end

	local owner = ent:GetOwner()
	if not IsValid(owner) or owner ~= LocalPlayer() then return end

	local vm = owner:GetViewModel()
	if not IsValid(vm) then return end

	local m = vm:GetBoneMatrix(vm:LookupBone(ent.CustomViewModelBone))
	local oPos, oAng = LocalToWorld(ent.CustomViewModelOffset, ent.CustomViewModelAngle, m:GetTranslation(), m:GetAngles())
	oPos, oAng = LocalToWorld(ent.MenuOffset, ent.MenuAngle, oPos, oAng)

	return oPos, oAng
end)

function SWEP:PostDrawViewModel(vm, weapon, ply)
	if not IsValid(self.CustomViewModelEntity) then
		self.CustomViewModelEntity = ClientsideModel(self.CustomViewModel)
		if not IsValid(self.CustomViewModelEntity) then
			return
		end

		-- Removing Bugbai from Viewmodel
		vm:ManipulateBonePosition(vm:LookupBone("ValveBiped.cube3"), Vector(0, 0, 100))
		vm:ManipulateBoneAngles(vm:LookupBone("ValveBiped.Bip01_Spine"), Angle(0, 0, -20))

		self.CustomViewModelEntity:SetNoDraw(true)
		self.CustomViewModelEntity:SetModelScale(self.CustomViewModelScale)
	end

	local m = vm:GetBoneMatrix(vm:LookupBone(self.CustomViewModelBone))
	local pos, ang = LocalToWorld(self.CustomViewModelOffset, self.CustomViewModelAngle, m:GetTranslation(), m:GetAngles())

	self.CustomViewModelEntity:SetPos(pos)
	self.CustomViewModelEntity:SetAngles(ang)

	self.CustomViewModelEntity:DrawModel()

	local interface = Star_Trek.LCARS.ActiveInterfaces[self.InterfaceId]
	if istable(interface) then
		interface.IVis = true

		render.SuppressEngineLighting(true)

		local iPos, iAng = Star_Trek.LCARS:GetInterfacePosAngle(self, interface.IPos, interface.IAng)

		for _, window in pairs(interface.Windows) do
			window.WPosG, window.WAngG = LocalToWorld(window.WPos, window.WAng, iPos, iAng)
			window.WVis = true

			Star_Trek.LCARS:DrawWindow(window.WPosG, window.WAngG, window, interface.AnimPos)
		end

		surface.SetAlphaMultiplier(1)
		render.SuppressEngineLighting(false)
	end
end
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

function SWEP:Holster(weapon)
	local owner = self:GetOwner()
	if not IsValid(owner) or owner ~= LocalPlayer() then return end

	local vm = owner:GetViewModel()
	if not IsValid(vm) then return end

	for i = 0, vm:GetBoneCount() - 1 do
		vm:ManipulateBonePosition(i, Vector())
		vm:ManipulateBoneAngles(i, Angle())
		vm:ManipulateBoneScale(i, Vector(1, 1, 1))
	end

	if IsValid(self.CustomViewModelEntity) then
		self.CustomViewModelEntity:Remove()
	end
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
	if not IsValid(self.CustomViewModelEntity) then
		self.CustomViewModelEntity = ClientsideModel(self.CustomViewModel)
		if not IsValid(self.CustomViewModelEntity) then
			return
		end

		-- Removing Bugbait from Viewmodel
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

			Star_Trek.LCARS:DrawWindow(window.WPosG, window.WAngG, window, interface.AnimPos, not interface.Closing)
		end

		surface.SetAlphaMultiplier(1)
		render.SuppressEngineLighting(false)
	end
end
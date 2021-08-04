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

function SWEP:GetPosAngle(world)
	local owner = self:GetOwner()
	if not IsValid(owner) then
		-- TODO: Implement without Bones
		return
	end

	if world then
		local m = owner:GetBoneMatrix(owner:LookupBone(self.CustomWorldModelBone))
		local oPos, oAng = LocalToWorld(self.CustomWorldModelOffset, self.CustomWorldModelAngle, m:GetTranslation(), m:GetAngles())
		oPos, oAng = LocalToWorld(self.MenuOffset, self.MenuAngle, oPos, oAng)

		return oPos, oAng
	else
		if owner ~= LocalPlayer()  then return end

		local vm = owner:GetViewModel()
		if not IsValid(vm) then return end

		local m = vm:GetBoneMatrix(vm:LookupBone(self.CustomViewModelBone))
		local oPos, oAng = LocalToWorld(self.CustomViewModelOffset, self.CustomViewModelAngle, m:GetTranslation(), m:GetAngles())
		oPos, oAng = LocalToWorld(self.MenuOffset, self.MenuAngle, oPos, oAng)

		return oPos, oAng
	end
end

function SWEP:DrawWindow(world)
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

function SWEP:PostDrawViewModel(vm, weapon, ply)
	self.DrawingViewModelActive = true

	if not IsValid(self.CustomViewModelEntity) then
		self.CustomViewModelEntity = ClientsideModel(self.CustomViewModel)
		if not IsValid(self.CustomViewModelEntity) then
			return
		end

		-- Removing Bugbait from Viewmodel
		vm:ManipulateBonePosition(vm:LookupBone("ValveBiped.cube3"), Vector(0, 0, 100))
		vm:ManipulateBoneAngles(vm:LookupBone("ValveBiped.Bip01_Spine"), Angle(0, 0, -20))

		self.CustomViewModelEntity:SetNoDraw(true)
		self.CustomViewModelEntity:SetModelScale(self.CustomScale)
	end

	local m = vm:GetBoneMatrix(vm:LookupBone(self.CustomViewModelBone))
	local pos, ang = LocalToWorld(self.CustomViewModelOffset, self.CustomViewModelAngle, m:GetTranslation(), m:GetAngles())

	self.CustomViewModelEntity:SetPos(pos)
	self.CustomViewModelEntity:SetAngles(ang)

	self.CustomViewModelEntity:DrawModel()
	self:DrawWindow(false)
end

function SWEP:DrawWorldModel(flags)
	self.DrawingViewModelActive = false

	if not IsValid(self.CustomWorldModelEntity) then
		self.CustomWorldModelEntity = ClientsideModel(self.WorldModel)
		if not IsValid(self.CustomWorldModelEntity) then
			return
		end

		self.CustomWorldModelEntity:SetNoDraw(true)
		self.CustomWorldModelEntity:SetModelScale(self.CustomScale)
	end

	local owner = self:GetOwner()
	if IsValid(owner) then
		local m = owner:GetBoneMatrix(owner:LookupBone(self.CustomWorldModelBone))
		local pos, ang = LocalToWorld(self.CustomWorldModelOffset, self.CustomWorldModelAngle, m:GetTranslation(), m:GetAngles())

		self.CustomWorldModelEntity:SetPos(pos)
		self.CustomWorldModelEntity:SetAngles(ang)

		self.CustomWorldModelEntity:DrawModel()
	else
		self:DrawModel()
	end
end
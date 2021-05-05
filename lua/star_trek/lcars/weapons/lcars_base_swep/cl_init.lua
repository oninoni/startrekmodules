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

	local viewModel = owner:GetViewModel()
	if not IsValid(viewModel) then return end

	local oPos, oAng = LocalToWorld(pos, ang, viewModel:GetPos(), viewModel:GetAngles())

	oAng:RotateAroundAxis(oAng:Forward(), -90)
	oAng:RotateAroundAxis(oAng:Up(), 180)

	oPos = oPos - oAng:Up() * 30
	oPos = oPos + oAng:Right() * 10

	return oPos, oAng
end)
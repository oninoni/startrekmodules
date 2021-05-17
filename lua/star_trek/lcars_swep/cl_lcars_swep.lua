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
--        LCARS SWEP | Client        --
---------------------------------------

hook.Add("Star_Trek.LCARS.OverridePosAng", "Star_Trek.LCARS_SWEP.OverrideSWEPViewmodel", function(ent, pos, ang)
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

hook.Add("Star_Trek.LCARS.OpenMenu", "Star_Trek.LCARS_SWEP.OpenSWEPMenu", function(id, interfaceData, interface)
	local ent = interfaceData.Ent
	if not ent.IsLCARS then return end
end)

hook.Add("Star_Trek.LCARS.CloseInterface", "Star_Trek.LCARS_SWEP.CloseSWEPInterface", function(id, interfaceData, interface)
	local ent = interfaceData.Ent
	if not ent.IsLCARS then return end
end)

net.Receive("Star_Trek.LCARS_SWEP.EnableScreenClicker", function()
	local ent = net.ReadEntity()
	local enabled = net.ReadBool()
	gui.EnableScreenClicker(enabled)

	if not IsValid(ent) then return end

	if enabled then
		ent.Panel = vgui.Create("DPanel")
		ent.Panel:SetSize(ScrW(), ScrH())
		ent.Panel:SetCursor("blank")
		function ent.Panel:Paint(ww, hh)
		end
	else
		if IsValid(ent.Panel) then
			ent.Panel:Remove()
		end
	end
end)
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
--        LCARS SWEP | Client        --
---------------------------------------

hook.Add("Star_Trek.LCARS.OverridePosAng", "Star_Trek.LCARS_SWEP.OverrideSWEPViewmodel", function(ent, pos, ang)
	if IsValid(ent) and ent:IsWeapon() and ent.IsLCARS then
		if ent.IsViewModelRendering then
			return ent:GetPosAngle()
		else
			return ent:GetPosAngle(true)
		end
	end
end)

hook.Add("Star_Trek.LCARS.PreventRender", "Star_Trek.LCARS_SWEP.PreventRender", function(interface, ignoreViewModel)
	local ent = interface.Ent
	if IsValid(ent) and ent:IsWeapon() and ent.IsLCARS then
		local owner = ent:GetOwner()
		if IsValid(owner) then
			if owner:GetActiveWeapon() ~= ent then
				return true
			end

			if not ignoreViewModel and ent.IsViewModelRendering then
				return true
			end
		end
	end
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
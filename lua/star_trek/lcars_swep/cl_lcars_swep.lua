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
	if IsValid(ent) and ent:IsWeapon() and ent.IsLCARS then
		if ent.DrawingViewModelActive then
			return ent:GetPosAngle(false)
		else
			return ent:GetPosAngle(true)
		end
	end
end)

hook.Add("Star_Trek.LCARS.PreventRender", "Star_Trek.LCARS_SWEP.PreventRender", function(interface)
	local ent = interface.Ent
	if IsValid(ent) and ent:IsWeapon() and ent.IsLCARS and ent.DrawingViewModelActive then
		return true
	end
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
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
--           PADD | Client           --
---------------------------------------

hook.Add("PostDrawTranslucentRenderables", "Star_Trek.PADD.Draw", function(isDrawingDepth, isDrawSkyBox)
	if isDrawSkyBox then return end
	if ( wp.drawing ) then return end

	local weapon = LocalPlayer():GetActiveWeapon()
	local window = weapon.Window

	if istable(window) then
		local viewModel = LocalPlayer():GetViewModel()
		local att = viewModel:GetAttachment(viewModel:LookupAttachment("muzzle"))
		local pos = att.Pos
		local ang = att.Ang

		pos = pos - ang:Forward() * 10
		ang:RotateAroundAxis(ang:Right(), 90)

		render.SuppressEngineLighting(true)

		window.WPos = pos
		window.WAng = ang

		cam.IgnoreZ(true)
		Star_Trek.LCARS:DrawWindow(pos, ang, window, 1)

		surface.SetAlphaMultiplier(1)
		render.SuppressEngineLighting(false)
	end
end)

net.Receive("Star_Trek.PADD.Enable", function()
	local ply = LocalPlayer()
	local weapon = ply:GetWeapon("padd_swep")
	if IsValid(weapon) then
		weapon.Window.WVis = true
		gui.EnableScreenClicker(true)
	end
end)

net.Receive("Star_Trek.PADD.Disable", function()
	local ply = LocalPlayer()
	local weapon = ply:GetWeapon("padd_swep")
	if IsValid(weapon) then
		weapon.Window.WVis = false
		gui.EnableScreenClicker(false)
	end
end)
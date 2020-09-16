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
--       Portal Window | Client      --
---------------------------------------

-- Render views from the portals
hook.Add( "RenderScene", "Star_Trek.RenderWindow", function( plyOrigin, plyAngle )

	wp.portals = ents.FindByClass( "linked_portal_window" )

	if ( not wp.portals ) then return end
	if ( wp.drawing ) then return end

	-- Disable phys gun glow and beam
	local oldWepColor = LocalPlayer():GetWeaponColor()
	LocalPlayer():SetWeaponColor( Vector( 0, 0, 0 ) )

	for _, portal in pairs( wp.portals ) do

		local exitPortal = portal:GetExit()
		if not IsValid(exitPortal) then continue end

		if not wp.shouldrender( portal ) then continue end
		if not portal:GetShouldDrawNextFrame() then continue end
		portal:SetShouldDrawNextFrame( false )

		hook.Call( "wp-prerender", GAMEMODE, portal, exitPortal, plyOrigin )
		
		render.PushRenderTarget( portal:GetTexture() )
			render.Clear( 0, 0, 0, 255, true, true )

			local oldClip = render.EnableClipping( true )
			render.PushCustomClipPlane( exitPortal:GetForward(), exitPortal:GetForward():Dot( exitPortal:GetPos() - exitPortal:GetForward() * 0.5 ) )

			local camOrigin = wp.TransformPortalPos( plyOrigin, portal, exitPortal )
			local camAngle = wp.TransformPortalAngle( plyAngle, portal, exitPortal )

			wp.drawing = true
			wp.drawingent = portal
				render.RenderView( {
					x = 0,
					y = 0,
					w = ScrW(),
					h = ScrH(),
					origin = camOrigin,
					angles = camAngle,
					dopostprocess = false,
					drawhud = false,
					drawmonitors = false,
					drawviewmodel = false,
					bloomtone = true
					--zfar = 1500
				} )
			wp.drawing = false
			wp.drawingent = nil

			render.PopCustomClipPlane()
			render.EnableClipping( oldClip )
		render.PopRenderTarget()
		
		hook.Call( "wp-postrender", GAMEMODE, portal, exitPortal, plyOrigin )
	end

	LocalPlayer():SetWeaponColor( oldWepColor )
end )

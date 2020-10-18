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

-- Render views from the windows
hook.Add( "RenderScene", "Star_Trek.RenderWindow", function( plyOrigin, plyAngle )
	wp.windows = ents.FindByClass( "linked_portal_window" )

	if ( not wp.windows ) then return end
	if ( wp.drawing ) then return end

	-- Disable phys gun glow and beam
	local oldWepColor = LocalPlayer():GetWeaponColor()
	LocalPlayer():SetWeaponColor( Vector( 0, 0, 0 ) )

	for _, window in pairs( wp.windows ) do
		local exitPortal = window:GetExit()
		if not IsValid(exitPortal) then continue end

		if not wp.shouldrender( window ) then continue end
		if not window:GetShouldDrawNextFrame() then continue end
		window:SetShouldDrawNextFrame( false )

		hook.Call( "wp-prerender", GAMEMODE, window, exitPortal, plyOrigin )

		render.PushRenderTarget( window:GetTexture() )
			render.Clear( 0, 0, 0, 255, true, true )

			local oldClip = render.EnableClipping( true )
			render.PushCustomClipPlane( exitPortal:GetForward(), exitPortal:GetForward():Dot( exitPortal:GetPos() - exitPortal:GetForward() * 0.5 ) )

			local camOrigin = wp.TransformPortalPos( plyOrigin, window, exitPortal )
			local camAngle = wp.TransformPortalAngle( plyAngle, window, exitPortal )

			wp.drawing = true
			wp.drawingent = window
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

		hook.Call( "wp-postrender", GAMEMODE, window, exitPortal, plyOrigin )
	end

	LocalPlayer():SetWeaponColor( oldWepColor )
end )

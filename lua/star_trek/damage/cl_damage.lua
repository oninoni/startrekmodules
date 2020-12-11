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
--          Damage | Client          --
---------------------------------------

Star_Trek.Damage.Entities = Star_Trek.Damage.Entities or {}

hook.Add("PreDrawTranslucentRenderables", "Star_Trek.Damage.DrawDamages", function(isDrawingDepth, isDrawingSkybox)
	if isDrawSkyBox then return end
	if ( wp.drawing ) then return end

	render.SetStencilWriteMask( 255 )
	render.SetStencilTestMask( 255 )
	render.SetStencilReferenceValue( 42 )

	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )

	for _, ent in pairs(Star_Trek.Damage.Entities) do
		if not IsValid(ent) then
			continue
		end

		local screenpos = ent:GetPos():ToScreen()
		if screenpos.visible == false then
			continue
		end

		render.ClearStencil()

		render.SetStencilEnable( true )
			render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )

			render.SetColorMaterial()
			local pos = ent:GetPos() + ent:GetForward() * ent.Offset

			local pos1 = pos + ent:GetRight() * ent.RightBorder + ent:GetUp() * ent.TopBorder
			local pos2 = pos - ent:GetRight() * ent.LeftBorder  + ent:GetUp() * ent.TopBorder
			local pos3 = pos - ent:GetRight() * ent.LeftBorder  - ent:GetUp() * ent.BottomBorder
			local pos4 = pos + ent:GetRight() * ent.RightBorder - ent:GetUp() * ent.BottomBorder
			render.DrawQuad(pos1, pos2, pos3, pos4, color_white)

			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

			render.OverrideDepthEnable(true, false)
			cam.IgnoreZ(true)
			render.SuppressEngineLighting(true)
			ent.ClientModel:DrawModel()
			render.SuppressEngineLighting(false)
			cam.IgnoreZ(false)
			render.OverrideDepthEnable(false, false)
		render.SetStencilEnable( false )
	end
end)
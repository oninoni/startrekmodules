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
--      LCARS Elements | Client      --
---------------------------------------

function Star_Trek.LCARS:GenerateElement(elementType, id, width, height, ...)
	local elementFunctions = self.Elements[elementType]
	if not istable(elementFunctions) then
		return false, "Invalid Element Type!"
	end

	local element = {
		Id = id,
		ElementWidth = width,
		ElementHeight = height,
	}
	setmetatable(element, {__index = elementFunctions})

	element:Initialize(...)

	local oldW, oldH = ScrW(), ScrH()
	render.SetViewPort(0, 0, element.Width, element.Height)

	render.PushRenderTarget(element.Texture)
	cam.Start2D()
		element:Draw()
	cam.End2D()
	render.PopRenderTarget()

	render.SetViewPort(0, 0, oldW, oldH)

	return true, element
end
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

function Star_Trek.LCARS:GenerateElement(elementType, id, style, width, height, ...)
	local elementFunctions = self.Elements[elementType]
	if not istable(elementFunctions) then
		return false, "Invalid Element Type!"
	end

	local element = {
		ElementType = elementType,
		Id = id,
		ElementWidth = width,
		ElementHeight = height,
		CurrentStyle = style,
	}
	setmetatable(element, {__index = elementFunctions})

	element:Initialize(...)
	element:GenerateTexture()


	return true, element
end
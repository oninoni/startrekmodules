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

	print("Generating", id, style)

	local element = {
		Id = id,
		ElementWidth = width,
		ElementHeight = height,
	}
	setmetatable(element, {__index = elementFunctions})

	element:Initialize(...)

	if style == "LCARS" then
		element:GenerateTexture()
	else
		element:SetStyle(style)
	end

	return true, element
end
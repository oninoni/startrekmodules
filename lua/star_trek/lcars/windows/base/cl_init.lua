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
--     LCARS Base Window | Client    --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(windowData)
	self.Elements = {}

	self.CurrentStyle = windowData.InitialStyle or "LCARS"

	return true
end

function SELF:OnPress(pos, animPos)
end

function SELF:OnDraw(pos, animPos)
end

function SELF:OnThink()
	for _, element in pairs(self.Elements) do
		element:OnThink()
	end
end

function SELF:GenerateElement(elementType, id, width, height, ...)
	local success, element = Star_Trek.LCARS:GenerateElement(elementType, id, self.CurrentStyle, width, height, ...)
	if not success then
		return false, element
	end

	self.Elements[id] = element

	return true, element
end

function SELF:SetStyle(style)
	if self.CurrentStyle == style then
		return
	end

	self.CurrentStyle = style

	for _, element in pairs(self.Elements) do
		element:SetStyle(style)
	end
end
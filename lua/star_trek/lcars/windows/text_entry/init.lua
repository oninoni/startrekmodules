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
--     LCARS Text Entry | Server     --
---------------------------------------

local SELF = WINDOW
function SELF:OnCreate(fallbackColor, title, titleShort, hFlip, lines)
	local success = SELF.Base.OnCreate(self, title, titleShort, hFlip)
	if not success then
		return false
	end

	if istable(lines) then
		self.Lines = lines
	else
		self:ClearLines()
	end

	self.Active = false
	self.FallbackColor = fallbackColor

	return true
end

function SELF:ClearLines()
	self.Lines = {}
end

function SELF:AddLine(text, color)
	table.insert(self.Lines, {
		Text = text,
		Color = color,
	})
end

function SELF:OnPress(interfaceData, ent, buttonId, callback)
	if buttonId == 1 then
		self.Active = not self.Active

		ent:EmitSound("star_trek.lcars_beep")

		return true
	end
end
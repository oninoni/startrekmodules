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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--     LCARS Text Entry | Server     --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
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

function SELF:GetClientData()
	local clientData = SELF.Base.GetClientData(self)

	clientData.Active = self.Active
	clientData.FallbackColor = self.FallbackColor

	clientData.Lines = self.Lines

	return clientData
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

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	if buttonId == 1 then
		self.Active = not self.Active

		interfaceData.Ent:EmitSound("star_trek.lcars_beep")

		return true
	end
end
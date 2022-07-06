---------------------------------------
---------------------------------------
--         Star Trek Modules         --
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
--    LCARS Transport Pad | Client   --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(padEntities, title, titleShort, hFlip)
	local success = SELF.Base.OnCreate(self, title, titleShort, hFlip)
	if not success then
		return false
	end

	self.Pads = {}

	for _, ent in pairs(padEntities) do
		if not IsValid(ent) then continue end

		local pad = {}
		pad.Data = ent

		table.insert(self.Pads, pad)
	end

	return self
end

function SELF:GetClientData()
	local clientData = SELF.Base.GetClientData(self)

	clientData.Pads = {}
	for i, pad in pairs(self.Pads) do
		clientPad = {
			Data = pad.Data:EntIndex(),

			Selected = pad.Selected,
			Disabled = pad.Disabled,
		}

		clientData.Pads[i] = clientPad
	end

	return clientData
end

function SELF:GetSelected()
	local data = {}

	for i, pad in pairs(self.Pads) do
		data[i] = pad.Selected
	end

	return data
end

function SELF:SetSelected(data)
	for i, pad in pairs(self.Pads) do
		pad.Selected = false

		for iData, selected in pairs(data) do
			if i == iData then
				pad.Selected = selected
				break
			end
		end
	end
end

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	local shouldUpdate = false

	local pad = self.Pads[buttonId]
	if istable(pad) and not pad.Disabled then
		pad.Selected = not (pad.Selected or false)
		shouldUpdate = true
	end

	if isfunction(callback) then
		local updated = callback(self, interfaceData, ply, buttonId)
		if updated then
			shouldUpdate = true
		end
	end

	interfaceData.Ent:EmitSound("star_trek.lcars_beep")

	return shouldUpdate
end
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
--    LCARS Transport Pad | Client   --
---------------------------------------

local SELF = WINDOW
function SELF:OnCreate(padNumber, title, titleShort, hFlip)
	local success = SELF.Base.OnCreate(self, title, titleShort, hFlip)
	if not success then
		return false
	end

	self.Pads = {}

	local radius = self.WindowHeight / 8
	local offset = radius * 2.5
	local outerX = 0.5 * offset
	local outerY = 0.866 * offset

	for _, ent in pairs(ents.GetAll()) do
		local name = ent:GetName()

		if string.StartWith(name, "TRPad") then
			local values = string.Split(string.sub(name, 6), "_")
			local k = tonumber(values[1])
			local n = tonumber(values[2])

			if n ~= padNumber then continue end

			local pad = {
				Name = k .. "_" .. n,
				Data = ent,
			}

			if k == 7 then
				pad.X = 0
				pad.Y = 0
				pad.Type = "Round"
			else
				if k == 3 or k == 4 then
					if k == 3 then
						pad.X = -offset
					else
						pad.X =  offset
					end

					pad.Y = 0
				else
					if k == 1 or k == 2 then
						pad.Y = outerY
					elseif k == 5 or k == 6 then
						pad.Y = -outerY
					end

					if k == 1 or k == 5 then
						pad.X = -outerX
					elseif k == 2 or k == 6 then
						pad.X = outerX
					end
				end

				pad.Type = "Hex"
			end

			-- Pad Offset (Frame)
			if hFlip then
				pad.X = pad.X - 20
			else
				pad.X = pad.X + 20
			end

			pad.Y = pad.Y + 30

			self.Pads[k] = pad
		end

	end

	return self
end

function SELF:GetSelected()
	local data = {}

	for _, pad in pairs(self.Pads) do
		data[pad.Name] = pad.Selected
	end

	return data
end

function SELF:SetSelected(data)
	for _, pad in pairs(self.Pads) do
		pad.Selected = false

		for name, selected in pairs(data) do
			if pad.Name == name then
				pad.Selected = selected
				break
			end
		end
	end
end

function SELF:OnPress(interfaceData, ent, buttonId, callback)
	local shouldUpdate = false

	local pad = self.Pads[buttonId]
	if istable(pad) then
		pad.Selected = not (pad.Selected or false)
		shouldUpdate = true
	end

	if isfunction(callback) then
		local updated = callback(self, interfaceData, buttonId)
		if updated then
			shouldUpdate = true
		end
	end

	if Star_Trek.LCARS.ActiveInterfaces[ent] and not Star_Trek.LCARS.ActiveInterfaces[ent].Closing then
		ent:EmitSound("star_trek.lcars_beep")
	end

	return shouldUpdate
end
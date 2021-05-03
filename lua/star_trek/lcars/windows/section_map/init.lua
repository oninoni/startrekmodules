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
--     LCARS Section Map | Server    --
---------------------------------------

local SELF = WINDOW
function SELF:OnCreate(deck, hFlip, objects)
	local success = SELF.Base.OnCreate(self, "", "DECK " .. deck, hFlip)
	if not success then
		return false
	end

	self:SetDeck(deck)
	self:SetObjects(objects)

	return self
end

function SELF:SetDeck(deck)
	self.Sections = {}

	local deckData = Star_Trek.Sections.Decks[deck]
	for sectionId, sectionData in pairs(deckData.Sections) do
		local sectionButtonData = {
			Id = sectionId,
			Name = sectionData.Name,
			Selected = false,
			Areas = {},
		}

		for _, areaData in pairs(sectionData.Areas) do
			local areaButtonData = {}

			areaButtonData.Width = math.abs(areaData.Min.x) + math.abs(areaData.Max.x)
			areaButtonData.Height = math.abs(areaData.Min.y) + math.abs(areaData.Max.y)
			areaButtonData.Pos = areaData.Pos - Vector(areaData.Min.x + areaData.Max.x, areaData.Min.y + areaData.Max.y, 0)
			areaButtonData.Pos.y = -areaButtonData.Pos.y

			areaButtonData.Pos = areaButtonData.Pos - Vector(areaButtonData.Width / 2, areaButtonData.Height / 2, 0)

			table.insert(sectionButtonData.Areas, areaButtonData)
		end

		table.insert(self.Sections, sectionButtonData)
	end
end

function SELF:SetObjects(objects)
	self.Objects = {}

	for _, object in pairs(objects or {}) do
		if istable(object) then
			local objectTable = table.Copy(object)
			objectTable.Pos.y = -objectTable.Pos.y

			table.insert(self.Objects, objectTable)
			continue
		end

		if IsEntity(object) then
			local objectTable = {
				Pos = object:GetPos(),
			}
			objectTable.Pos.y = -objectTable.Pos.y

			if object:IsPlayer() then
				objectTable.Color = Star_Trek.LCARS.ColorRed
			else
				objectTable.Color = Star_Trek.LCARS.ColorBlue
			end

			table.insert(self.Objects, objectTable)
			continue
		end
	end
end

function SELF:GetSelected()
	local data = {}

	for _, sectionData in pairs(self.Sections) do
		data[sectionData.Id] = sectionData.Selected
	end

	return data
end

function SELF:SetSelected(data)
	self:SetObjects({})

	for _, sectionData in pairs(self.Sections) do
		if data[sectionData.Id] then
			sectionData.Selected = true
		else
			sectionData.Selected = false
		end
	end
end

function SELF:SetSectionActive(sectionId, active)
	local selected = self:GetSelected()
	selected[sectionId] = active

	self:SetSelected(selected)
end

function SELF:OnPress(interfaceData, ent, buttonId, callback)
	local shouldUpdate = false

	return shouldUpdate
end
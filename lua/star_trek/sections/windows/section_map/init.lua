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
--     LCARS Section Map | Server    --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(deck, hFlip, objects)
	local success = SELF.Base.OnCreate(self, "", "DECK " .. deck, hFlip)
	if not success then
		return false
	end

	self:SetDeck(deck, objects)

	return self
end


function SELF:GetClientData()
	local clientData = SELF.Base.GetClientData(self)

	clientData.Sections = self.Sections
	clientData.Objects = self.Objects

	return clientData
end

function SELF:SetDeck(deck, objects)
	self.Sections = {}

	local success, deckData = Star_Trek.Sections:GetDeck(deck)
	if not success then return end

	for sectionId, sectionData in pairs(deckData.Sections) do
		local sectionButtonData = {
			Id = sectionId,
			Name = sectionData.Name,
			Selected = false,
			Areas = {},
		}

		for _, areaData in pairs(sectionData.Areas) do
			local areaButtonData = {}

			areaButtonData.Pos = areaData.Min
			areaButtonData.Size = areaData.Max - areaData.Min

			table.insert(sectionButtonData.Areas, areaButtonData)
		end

		self.Sections[sectionId] = sectionButtonData
	end

	self:SetObjects(objects)
end

function SELF:SetObjects(objects)
	self.Objects = {}

	for _, object in pairs(objects or {}) do
		if istable(object) then
			if isvector(object.Pos) then
				local objectTable = table.Copy(object)
				objectTable.Pos = objectTable.Pos - Star_Trek.Sections.GlobalOffset
				objectTable.Pos[2] = -objectTable.Pos[2]

				objectTable.Color = objectTable.Color or Star_Trek.LCARS.ColorBlue

				table.insert(self.Objects, objectTable)
				continue
			end
			if istable(object.Group) then
				local objectTable = table.Copy(object)
				for i = 1, #objectTable.Group do
					objectTable.Group[i] = objectTable.Group[i] - Star_Trek.Sections.GlobalOffset
					objectTable.Group[i][2] = -objectTable.Group[i][2]
				end

				objectTable.Color = objectTable.Color or Star_Trek.LCARS.ColorBlue

				table.insert(self.Objects, objectTable)
				continue
			end

			if IsEntity(object.Entity) then
				object = object.Entity
			end
		end

		if IsEntity(object) then
			local objectTable = {
				Pos = object:GetPos(),
			}
			objectTable.Pos = objectTable.Pos - Star_Trek.Sections.GlobalOffset
			objectTable.Pos[2] = -objectTable.Pos[2]

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
	for sectionId, sectionData in pairs(self.Sections) do
		data[sectionId] = sectionData.Selected
	end

	return data
end

function SELF:SetSelected(data)
	self:SetObjects({})

	for sectionId, sectionData in pairs(self.Sections) do
		if data[sectionId] then
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

function SELF:OnPress(interfaceData, ply, buttonId, callback)
	local shouldUpdate = false
	return shouldUpdate
end


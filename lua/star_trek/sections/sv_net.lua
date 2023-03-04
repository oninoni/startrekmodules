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
--    Sections Networking | Server   --
---------------------------------------

function Star_Trek.Sections:GetClientData()
	local clientDecks = {}

	for deck, deckData in pairs(self.Decks) do
		local clientDeckData = {}
		clientDeckData.Bounds = deckData.Bounds

		clientDeckData.Sections = {}
		for sectionId, sectionData in pairs(deckData.Sections) do
			local clientSectionData = {}
			clientSectionData.RealId = sectionData.RealId
			clientSectionData.Name = sectionData.Name

			clientSectionData.Areas = sectionData.Areas

			clientDeckData.Sections[sectionId] = clientSectionData
		end

		clientDecks[deck] = clientDeckData
	end

	hook.Run("Star_Trek.Sections.GetClientData", clientDecks)

	return clientDecks
end

util.AddNetworkString("Star_Trek.Sections.Sync")
function Star_Trek.Sections:Sync(ply)
	local clientDecks = Star_Trek.Sections:GetClientData()

	if IsValid(ply) and ply:IsPlayer() then
		net.Start("Star_Trek.Sections.Sync")
			Star_Trek.Util:WriteNetTable(clientDecks)
		net.Send(ply)
	else
		net.Start("Star_Trek.Sections.Sync")
			Star_Trek.Util:WriteNetTable(clientDecks)
		net.Broadcast()
	end

end

hook.Add("PlayerInitialSpawn", "Star_Trek.Sections.Sync", function(ply)
	Star_Trek.Sections:Sync(ply)
end)
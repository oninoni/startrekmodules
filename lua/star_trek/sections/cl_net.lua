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
--    Sections Networking | Client   --
---------------------------------------

net.Receive("Star_Trek.Sections.Sync", function()
	Star_Trek.Sections.Decks = Star_Trek.Util:ReadNetTable()
end)
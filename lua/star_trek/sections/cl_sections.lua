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
--         Sections | Client         --
---------------------------------------

net.Receive("Star_Trek.Sections.Sync", function()
	Star_Trek.Sections.Decks = net.ReadTable()
end)
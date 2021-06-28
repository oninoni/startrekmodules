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
--           World | Server          --
---------------------------------------

util.AddNetworkString("Star_Trek.World.Init")
util.AddNetworkString("Star_Trek.World.SyncOnJoin")
util.AddNetworkString("Star_Trek.World.Remove")
util.AddNetworkString("Star_Trek.World.Sync")

function Star_Trek.World:Init(i, pos, ang, model, scale)
	self:AddObject(i, pos, ang, model, scale)

	net.Start("Star_Trek.World.Init")

	net.Broadcast()
end
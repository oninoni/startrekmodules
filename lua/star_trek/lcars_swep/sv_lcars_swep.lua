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
--        LCARS SWEP | Server        --
---------------------------------------

util.AddNetworkString("Star_Trek.LCARS.EnableScreenClicker")
function Star_Trek.LCARS:EnableScreenClicker(ply, enabled)
	net.Start("Star_Trek.LCARS.EnableScreenClicker")
		net.WriteBool(enabled)
	net.Send(ply)
end

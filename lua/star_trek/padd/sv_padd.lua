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
--           PADD | Server           --
---------------------------------------

function Star_Trek.PADD:Enable(padd, interfaceName)
	local ply = padd:GetOwner()
	if not IsValid(ply) then
		return false, "Invalid Owner"
	end

	print(Star_Trek.LCARS:OpenInterface(ply, padd, "replicator"))

	return true
end
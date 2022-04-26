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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--           Doors | Shared          --
---------------------------------------

function Star_Trek.Doors:IsDoor(ent)
	if ent:GetClass() == "prop_dynamic" and self.ModelNames[ent:GetModel()] then
		return true
	end

	return false
end
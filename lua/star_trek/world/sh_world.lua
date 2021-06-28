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
--           World | Shared          --
---------------------------------------

Star_Trek.World.Objects = {}

function Star_Trek.World:AddObject(i, pos, ang, model, scale)
	local obj = {
		Pos = pos,
		Ang = ang,

		Scale = scale,
		Model = model,
	}

	self.Objects[i] = obj
end

function Star_Trek.World:RemoveObject(i)
	self.Objects[i] = nil
end
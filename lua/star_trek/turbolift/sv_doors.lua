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
--      Turbolift Doors | Server     --
---------------------------------------

function Star_Trek.Turbolift:OpenDoors(ent)
	local door = ent:GetChildren()[1]
	if IsValid(door) then
		door:Fire("AddOutput", "lcars_locked 0")
		door:Fire("SetAnimation", "open")
	end
end

function Star_Trek.Turbolift:UnlockDoors(ent)
	local door = ent:GetChildren()[1]
	if IsValid(door) then
		door:Fire("AddOutput", "lcars_locked 0")
	end
end

function Star_Trek.Turbolift:LockDoors(ent)
	local door = ent:GetChildren()[1]
	if IsValid(door) then
		door:Fire("AddOutput", "lcars_locked 1")
	end
end

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
--      World Entities | Shared      --
---------------------------------------

Star_Trek.World.Entities = Star_Trek.World.Entities or {}

function Star_Trek.World:InitEntity(id, class, data)
	local ent = {}
	ent.Id = id

	local entClass = self.EntityClasses[class]
	if not istable(entClass) then
		return false, "Invalid Class \"" .. class .. "\""
	end
	setmetatable(ent, {__index = entClass})
	ent.Class = class

	ent:Init(data)
	self.Entities[id] = ent

	return true, ent
end

function Star_Trek.World:TerminateEntity(id)
	local ent = self.Entities[id]

	if not istable(ent) then
		return false, "World Entity with id \"" .. id .. "\" does not exist. Skipping Unload."
	end

	ent:Terminate()
	self.Entities[id] = nil

	return true
end
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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--      World Entities | Shared      --
---------------------------------------

Star_Trek.World.Entities = Star_Trek.World.Entities or {}

function Star_Trek.World:GetEntity(id)
	return self.Entities[id]
end

function Star_Trek.World:InitEntity(id, class, ...)
	local ent = {}
	ent.Id = id

	local entClass = self.EntityClasses[class]
	if not istable(entClass) then
		return false, "Invalid Class \"" .. class .. "\""
	end

	setmetatable(ent, {__index = entClass})
	ent.Class = class

	ent:Init(...)
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

function Star_Trek.World:Think(deltaT)
	for _, ent in ipairs(self.Entities) do
		ent:Think(deltaT)

		if SERVER and ent.Updated then
			ent:Update()
		end
	end

	if CLIENT then
		self:RenderThink()
	end
end

local nextThink = SysTime()
local lastTime = SysTime()
hook.Add("Think", "Star_Trek.World.Think", function()
	local sysTime = SysTime()
	if sysTime < nextThink then
		return
	end
	nextThink = sysTime + 0.025

	local deltaT = sysTime - lastTime
	lastTime = sysTime

	Star_Trek.World:Think(deltaT)
end)
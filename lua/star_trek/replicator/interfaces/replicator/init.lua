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
--     LCARS Replicator | Server     --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

include("util.lua")

SELF.BaseInterface = "base"

SELF.LogType = "Replicator"

-- Opens the replicator menu.
function SELF:Open(ent)
	local categories, categoryCount = self:GenerateCategories(ent)

	local success, window = Star_Trek.LCARS:CreateWindow(
		"category_list",
		Vector(0, 10, 0),
		Angle(0, 0, 0),
		nil,
		500,
		500,
		function(windowData, interfaceData, ply, categoryId, buttonId, buttonData)
			if buttonId then
				local selected = windowData.Selected
				local categoryData = windowData.Categories[selected]
				if istable(categoryData) then
					if istable(Star_Trek.Logs) then
						Star_Trek.Logs:AddEntry(ent, ply, "Replicating " .. buttonData.Name)
					end

					local pos = ent:LocalToWorld(ent.ReplicatePos or Vector(5, 0, -8))
					local ang = ent:LocalToWorldAngles(ent.ReplicateAng or Angle(0, 0, 0))
					Star_Trek.Replicator:CreateObject(buttonData.Data, pos, ang)
				end

				interfaceData:Close()
			else
				if categoryId == categoryCount + 1 then
					local pos = ent:LocalToWorld(ent.ReplicatePos or Vector(5, 0, -8))

					local targets = ents.FindInSphere(pos, 20)
					local cleanEntities = {}
					for _, target in pairs(targets) do
						if target.Replicated then
							table.insert(cleanEntities, target)
						end
					end

					if #cleanEntities == 0 then
						ent:EmitSound("star_trek.lcars_error")
					else
						if istable(Star_Trek.Logs) then
							Star_Trek.Logs:AddEntry(ent, ply, "Activating Recycler")
						end

						for _, cleanEnt in pairs(cleanEntities) do
							Star_Trek.Replicator:RecycleObject(cleanEnt)
						end
					end

					interfaceData:Close()

					return false
				elseif categoryId == categoryCount + 2 then
					windowData:Close()

					return false
				end
			end
		end,
		categories,
		"REPLICATOR",
		"REPL",
		true
	)
	if not success then
		return false, menuWindow
	end

	return true, {window}
end

-- Wrap for use in Map.
function Star_Trek.LCARS:OpenReplicatorMenu()
	Star_Trek.LCARS:OpenInterface(TRIGGER_PLAYER, CALLER, "replicator")
end
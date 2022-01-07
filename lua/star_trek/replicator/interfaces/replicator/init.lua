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
--     LCARS Replicator | Server     --
---------------------------------------

include("util.lua")

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = "base"

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
		function(windowData, interfaceData, categoryId, buttonId)
			if buttonId then
				local selected = windowData.Selected
				local categoryData = windowData.Categories[selected]
				if istable(categoryData) then
					local buttonData = categoryData.Buttons[buttonId]

					if istable(buttonData) then
						local pos, angle = Star_Trek.LCARS:GetInterfacePosAngleGlobal(ent)
						pos = pos + angle:Up() * -7
						pos = pos + angle:Right() * 6

						Star_Trek.Replicator:CreateObject(buttonData.Data, pos, ent:GetAngles())
					end
				end

				interfaceData:Close()
			else
				if categoryId == categoryCount + 1 then
					local pos, angle = Star_Trek.LCARS:GetInterfacePosAngleGlobal(ent)
					pos = pos + angle:Right() * 6

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
function Star_Trek.LCARS:OpenReplicatorMenu()
	local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
	if not success then
		Star_Trek:Message(ent)
		return
	end

	local interfaceData = self.ActiveInterfaces[ent]
	if istable(interfaceData) then
		return
	end

	local categories = table.Copy(Star_Trek.Replicator.Categories)
	local categoryCount = #categories

	table.insert(categories, {
		Name = "CLEAN",
		Color = Star_Trek.LCARS.ColorOrange,
		Buttons = {},
	})

	table.insert(categories, {
		Name = "CLOSE",
		Color = Star_Trek.LCARS.ColorRed,
		Buttons = {},
	})

	local success2, window = Star_Trek.LCARS:CreateWindow(
		"category_list",
		Vector(0, 10, 0),
		Angle(0, 0, 0),
		nil,
		500,
		500,
		function(windowData, interfaceData, ent, categoryId, buttonId)
			if buttonId then
				local selected = windowData.Selected
				local categoryData = windowData.Categories[selected]
				if istable(categoryData) then
					local buttonData = categoryData.Buttons[buttonId]

					if istable(buttonData) then
						local pos, angle = Star_Trek.LCARS:GetInterfacePosAngle(ent)
						pos = pos + angle:Up() * -7
						pos = pos + angle:Right() * 6

						Star_Trek.Replicator:CreateObject(buttonData.Data, pos, ent:GetAngles())
					end
				end

				Star_Trek.LCARS:CloseInterface(ent)
			else
				if categoryId == categoryCount + 1 then
					local pos, angle = Star_Trek.LCARS:GetInterfacePosAngle(ent)
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

					Star_Trek.LCARS:CloseInterface(ent)
				elseif categoryId == categoryCount + 2 then
					ent:EmitSound("star_trek.lcars_close")
					Star_Trek.LCARS:CloseInterface(ent)
				end
			end
		end,
		categories,
		"REPLICATOR",
		"REPL",
		true
	)
	if not success2 then
		Star_Trek:Message(menuWindow)
	end

	local windows = Star_Trek.LCARS:CombineWindows(
		window
	)

	local success3, error = self:OpenInterface(ent, windows)
	if not success3 then
		Star_Trek:Message(error)
		return
	end
end
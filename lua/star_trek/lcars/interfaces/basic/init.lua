local basicUtil = include("util.lua")

-- Opening general purpose menus.
function Star_Trek.LCARS:OpenMenu()
	local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
	if not success then
		-- Error Message
		Star_Trek:Message(ent)
		return
	end

	local interfaceData = self.ActiveInterfaces[ent]
	if istable(interfaceData) then
		return
	end

	local triggerEntity = ent:GetParent()
	if not IsValid(triggerEntity) then
		triggerEntity = ent
	end

	local keyValues = triggerEntity.LCARSKeyData
	if not istable(keyValues) then
		Star_Trek:Message("Invalid Key Values on OpenMenu")
		return
	end

	local buttons = basicUtil.GenerateButtons(keyValues)

	local scale = tonumber(keyValues["lcars_scale"])
	local width = tonumber(keyValues["lcars_width"])
	local height = tonumber(keyValues["lcars_height"])
	local title = keyValues["lcars_title"]
	local titleShort = keyValues["lcars_title_short"]
	if titleShort == false then
		titleShort = ""
	end

	if not height then
		height = math.max(2, math.min(6, table.maxn(buttons))) * 35 + 80
	end
	local success, window = self:CreateWindow(
		"button_list",
		Vector(),
		Angle(),
		scale,
		width,
		height,
		function(windowData, interfaceData, ent, buttonId)
			local triggerEntity = ent:GetParent()
			if not IsValid(triggerEntity) then
				triggerEntity = ent
			end

			if buttonId > 4 then
				local name = triggerEntity:GetName()
				local caseEntities = ents.FindByName(name .. "_case")
				for _, caseEnt in pairs(caseEntities) do
					if IsValid(caseEnt) then
						caseEnt:Fire("InValue", buttonId - 4)
					end
				end
			else
				triggerEntity:Fire("FireUser" .. buttonId)
			end

			local keyValues = triggerEntity.LCARSKeyData
			if istable(keyValues) and keyValues["lcars_keep_open"] then
				return
			end

			ent:EmitSound("star_trek.lcars_close")
			Star_Trek.LCARS:CloseInterface(ent)
		end,
		buttons,
		title,
		titleShort
	)
	if not success then
		Star_Trek:Message(window)
		return
	end

	local windows = Star_Trek.LCARS:CombineWindows(window)

	local success, error = self:OpenInterface(ent, windows)
	if not success then
		Star_Trek:Message(error)
		return
	end
end

-- Update general purpose menus.
hook.Add("Think", "Star_Trek.LCARS.BasicInterface", function()
	for ent, interfaceData in pairs(Star_Trek.LCARS.ActiveInterfaces) do
		if IsValid(ent) then
			local triggerEntity = ent:GetParent()
			if not IsValid(triggerEntity) then
				triggerEntity = ent
			end

			if triggerEntity.LCARSMenuChanged then
				local buttons = basicUtil.GenerateButtons(triggerEntity.LCARSKeyData)
				for i, button in pairs(buttons) do
					interfaceData.Windows[1].Buttons[i].Name = button.Name
					interfaceData.Windows[1].Buttons[i].Disabled = button.Disabled
				end

				Star_Trek.LCARS:UpdateWindow(ent, 1)

				triggerEntity.LCARSMenuChanged = false
			end
		end
	end
end)

-- Detect updates in "lcars_name_i", "lcars_disabled_i".
hook.Add("Star_Trek.ChangedKeyValue", "Star_Trek.LCARS.BasicInterface", function(ent, key, value)
	if string.StartWith(key, "lcars_name_") or string.StartWith(key, "lcars_disabled_") then
		local keyValues = ent.LCARSKeyData
		if istable(keyValues) and keyValues["lcars_keep_open"] then
			ent.LCARSMenuChanged = true
		end
	end
end)
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
--   LCARS Basic Interface | Server  --
---------------------------------------

local basicUtil = include("util.lua")

-- Opening general purpose menus.
function Star_Trek.LCARS:OpenMenu()
	local success1, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
	if not success1 then
		Star_Trek:Message(ent)
		return
	end

	if istable(self.ActiveInterfaces[ent]) then
		return
	end

	local triggerEntity = ent:GetParent()
	if not IsValid(triggerEntity) then
		triggerEntity = ent
	end

	local success2, buttons, scale, width, height, title, titleShort = basicUtil.GetButtonData(triggerEntity)
	if not success2 then
		Star_Trek:Message(buttons)
		return
	end

	local success3, window = self:CreateWindow(
		"button_list",
		Vector(),
		Angle(),
		scale,
		width,
		height,
		function(windowData, interfaceData, buttonId)
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
	if not success3 then
		Star_Trek:Message(window)
		return
	end

	local success4, error = self:OpenInterface(ent, window)
	if not success4 then
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
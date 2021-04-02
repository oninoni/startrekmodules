local transporterUtil = include("windowUtil.lua")

function Star_Trek.LCARS:OpenTransporterMenu()
	local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
	if not success then
		Star_Trek:Message(ent)
		return
	end

	local interfaceData = self.ActiveInterfaces[ent]
	if istable(interfaceData) then
		return
	end

	local padNumber = false
	local consoleName = ent:GetName()
	if isstring(consoleName) and string.StartWith(consoleName, "TRConsole") then
		local split = string.Split(consoleName, "_")
		padNumber = tonumber(split[2])
	end

	local success, sourceMenuTable = transporterUtil.CreateWindowTable(
		Vector(-13, -2, 6),
		Angle(5, 15, 30),
		350,
		false,
		Vector(-31, -12, 17),
		Angle(15, 45, 60),
		500,
		500,
		false,
		false,
		padNumber
	)
	if not success then
		Star_Trek:Message(sourceMenuTable)
		return
	end
	local success, error = sourceMenuTable:SelectType(1)
	if not success then
		Star_Trek:Message(error)
		return
	end

	local success, targetMenuTable = transporterUtil.CreateWindowTable(
		Vector(13, -2, 6),
		Angle(-5, -15, 30),
		350,
		false,
		Vector(31, -12, 17),
		Angle(-15, -45, 60),
		500,
		500,
		false,
		true,
		padNumber
	)
	if not success then
		Star_Trek:Message(targetMenuTable)
		return
	end
	local success, error = targetMenuTable:SelectType(2)
	if not success then
		Star_Trek:Message(error)
		return
	end

	local success, sliderWindow = Star_Trek.LCARS:CreateWindow("transport_slider", Vector(0, -2, 6), Angle(0, 0, 30), 30, 200, 200, function(windowData, interfaceData, ent, buttonId)
		transporterUtil.TriggerTransporter(self.ActiveInterfaces[ent])
	end)
	if not success then
		Star_Trek:Message(sliderWindow)
		return
	end

	local windows = Star_Trek.LCARS:CombineWindows(
		sourceMenuTable.MenuWindow,
		sourceMenuTable.MainWindow,
		targetMenuTable.MenuWindow,
		targetMenuTable.MainWindow,
		sliderWindow
	)

	local success, error = self:OpenInterface(ent, windows)
	if not success then
		Star_Trek:Message(error)
		return
	end

	local interfaceData = self.ActiveInterfaces[ent]
	interfaceData.SourceMenuTable = sourceMenuTable
	interfaceData.TargetMenuTable = targetMenuTable
end

function Star_Trek.LCARS:OpenConsoleTransporterMenu()
	local success, ent = self:GetInterfaceEntity(TRIGGER_PLAYER, CALLER)
	if not success then
		Star_Trek:Message(ent)
		return
	end

	local interfaceData = self.ActiveInterfaces[ent]
	if istable(interfaceData) then
		return
	end

	local success, sourceMenuTable = transporterUtil.CreateWindowTable(
		Vector(-22, -34, 8.2),
		Angle(0, 0, -90),
		500,
		false,
		Vector(-28, -5, -2),
		Angle(0, 0, 0),
		500,
		700,
		false,
		false
	)
	if not success then
		Star_Trek:Message(sourceMenuTable)
		return
	end
	local success, error = sourceMenuTable:SelectType(1)
	if not success then
		Star_Trek:Message(error)
		return
	end

	local success, targetMenuTable = transporterUtil.CreateWindowTable(
		Vector(22, -34, 8.2),
		Angle(0, 0, -90),
		500,
		true,
		Vector(28, -5, -2),
		Angle(0, 0, 0),
		500,
		700,
		true,
		true
	)
	if not success then
		Star_Trek:Message(targetMenuTable)
		return
	end
	local success, error = targetMenuTable:SelectType(2)
	if not success then
		Star_Trek:Message(error)
		return
	end

	local success, sliderWindow = Star_Trek.LCARS:CreateWindow(
		"transport_slider",
		Vector(0, -34, 8),
		Angle(0, 0, -90),
		20,
		200,
		200,
		function(windowData, interfaceData, ent, buttonId)
			transporterUtil.TriggerTransporter(self.ActiveInterfaces[ent])
		end
	)
	if not success then
		Star_Trek:Message(sliderWindow)
		return
	end

	local windows = Star_Trek.LCARS:CombineWindows(
		sourceMenuTable.MenuWindow,
		sourceMenuTable.MainWindow,
		targetMenuTable.MenuWindow,
		targetMenuTable.MainWindow,
		sliderWindow
	)

	local success, error = self:OpenInterface(ent, windows)
	if not success then
		Star_Trek:Message(error)
		return
	end

	interfaceData = self.ActiveInterfaces[ent]
	interfaceData.SourceMenuTable = sourceMenuTable
	interfaceData.TargetMenuTable = targetMenuTable
end
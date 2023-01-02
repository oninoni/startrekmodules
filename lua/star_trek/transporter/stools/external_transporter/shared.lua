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
--     Server | Transporter STool    --
---------------------------------------

if not istable(TOOL) then Star_Trek:LoadAllModules() return end

TOOL.Category = "ST:RP"
TOOL.Name = "Transporter External-Location-Tool"
TOOL.ConfigName = ""

local textEntry

if (CLIENT) then
	TOOL.Information = {
		{ name = "left" },
		{ name = "right" },
		{ name = "reload" }
	}

	language.Add("tool.external_transporter.name", "Transporter External-Location-Tool")
	language.Add("tool.external_transporter.desc", "Allows placement of locations for the transporter. Every positions allows 7 people to beam down. Please leave enough space around them!")
	language.Add("tool.external_transporter.left", "Place Transporter Beam Location")
	language.Add("tool.external_transporter.right", "Remove Closest Transporter Beam Location")
	language.Add("tool.external_transporter.reload", "Override Closest Transporter Beam Location Name")

	local externals = {}
	net.Receive("Star_Trek.TransporterTool.Sync", function()
		externals = net.ReadTable()
	end)

	net.Receive("Star_Trek.TransporterTool.Create", function()
		local hitPos = net.ReadVector()

		net.Start("Star_Trek.TransporterTool.Create")
			net.WriteVector(hitPos)
			net.WriteString(textEntry:GetText())
		net.SendToServer()
	end)

	net.Receive("Star_Trek.TransporterTool.Edit", function()
		local id = net.ReadInt(32)

		net.Start("Star_Trek.TransporterTool.Edit")
			net.WriteInt(id, 32)
			net.WriteString(textEntry:GetText())
		net.SendToServer()
	end)

	local innerRadius = 5
	local outerRadius = 10
	local height = 30
	local function renderTransporterLocation(pos, name)
		render.DrawLine(pos, pos + Vector(-outerRadius, -outerRadius, height), colorSelected)
		render.DrawLine(pos, pos + Vector(-outerRadius,  outerRadius, height), colorSelected)
		render.DrawLine(pos, pos + Vector( outerRadius, -outerRadius, height), colorSelected)
		render.DrawLine(pos, pos + Vector( outerRadius,  outerRadius, height), colorSelected)

		render.DrawWireframeBox(pos, Angle(), Vector(-outerRadius, -outerRadius, height), Vector(outerRadius, outerRadius, height + outerRadius * 2), colorSelected)
		render.DrawWireframeSphere(pos + Vector(0, 0, height + outerRadius), innerRadius, 32, 32, colorSelected)
		render.DrawWireframeBox(pos, Angle(), Vector(-innerRadius, -innerRadius, height + (outerRadius - innerRadius)), Vector(innerRadius, innerRadius, height + (outerRadius - innerRadius) + innerRadius * 2), colorSelected)

		render.DrawLine(pos + Vector(0, 0, height * 1.5 + outerRadius * 2), pos + Vector(-outerRadius, -outerRadius, height + outerRadius * 2), colorSelected)
		render.DrawLine(pos + Vector(0, 0, height * 1.5 + outerRadius * 2), pos + Vector(-outerRadius,  outerRadius, height + outerRadius * 2), colorSelected)
		render.DrawLine(pos + Vector(0, 0, height * 1.5 + outerRadius * 2), pos + Vector( outerRadius, -outerRadius, height + outerRadius * 2), colorSelected)
		render.DrawLine(pos + Vector(0, 0, height * 1.5 + outerRadius * 2), pos + Vector( outerRadius,  outerRadius, height + outerRadius * 2), colorSelected)

		if isstring(name) and name ~= "" then
			local dy = EyeAngles():Up()
			local dx = -EyeAngles():Right()
			local ang = dx:AngleEx(dx:Cross(-dy))
			ang:RotateAroundAxis(EyeAngles():Forward(), 180)

			cam.Start3D2D(pos + Vector(0, 0, height * 1.5 + outerRadius * 2.2), ang, 0.1)
				draw.SimpleText(name or "", "LCARSText", 0, 0, color_white)
			cam.End3D2D()
		end
	end

	-- Renders the marker.
	hook.Add( "HUDPaint", "TransporterTool.Render", function()
		local toolSwep = LocalPlayer():GetActiveWeapon()
		if not IsValid(toolSwep) or toolSwep:GetClass() ~= "gmod_tool" then
			return
		end

		local toolTable = LocalPlayer():GetTool()
		if not istable(toolTable) or toolTable.Mode ~= "external_transporter" then
			return
		end

		cam.Start3D()
			for _, externalData in pairs(externals or {}) do
				renderTransporterLocation(externalData.Pos, externalData.Name)
			end
		cam.End3D()
	end )
end

if SERVER then
	util.AddNetworkString("Star_Trek.TransporterTool.Sync")
	function TOOL:Sync()
		net.Start("Star_Trek.TransporterTool.Sync")
			net.WriteTable(Star_Trek.Transporter.Externals)
		net.Send(self:GetOwner())
	end

	util.AddNetworkString("Star_Trek.TransporterTool.Create")
	net.Receive("Star_Trek.TransporterTool.Create", function(len, ply)
		local hitPos = net.ReadVector()
		local name = net.ReadString()

		local tool = ply:GetTool()
		if tool.Mode ~= "external_transporter" then return end

		local externalData = {
			Name = name,
			Pos = hitPos
		}

		table.insert(Star_Trek.Transporter.Externals, externalData)

		tool:Sync()
	end)

	util.AddNetworkString("Star_Trek.TransporterTool.Edit")
	net.Receive("Star_Trek.TransporterTool.Edit", function(len, ply)
		local id = net.ReadInt(32)
		local name = net.ReadString()

		local tool = ply:GetTool()
		if tool.Mode ~= "external_transporter" then return end

		local externalData = Star_Trek.Transporter.Externals[id]
		externalData.Name = name

		tool:Sync()
	end)

	function TOOL:Deploy()
		self:Sync()
	end
end

function TOOL:LeftClick(tr)
	if (CLIENT) then return true end

	local hitPos = tr.HitPos
	if not isvector(hitPos) then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return true end

	net.Start("Star_Trek.TransporterTool.Create")
		net.WriteVector(hitPos)
	net.Send(owner)

	hook.Run("Star_Trek.Transporter.ExternalsChanged")

	self:Sync()
end

function TOOL:RightClick(tr)
	if (CLIENT) then return true end

	local hitPos = tr.HitPos
	if not isvector(hitPos) then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return true end

	local closest = nil
	local closestDistance = math.huge

	for i, externalData in pairs(Star_Trek.Transporter.Externals) do
		local pos = externalData.Pos
		local distance = pos:Distance(hitPos)
		if distance < closestDistance then
			closest = i
			closestDistance = distance
		end
	end

	if closest ~= nil then
		table.remove(Star_Trek.Transporter.Externals, closest)

		hook.Run("Star_Trek.Transporter.ExternalsChanged")
	end

	self:Sync()
end

-- Remove Data
function TOOL:Reload(tr)
	if (CLIENT) then return true end

	local hitPos = tr.HitPos
	if not isvector(hitPos) then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return true end

	local closest = nil
	local closestDistance = math.huge

	for i, externalData in pairs(Star_Trek.Transporter.Externals) do
		local pos = externalData.Pos
		local distance = pos:Distance(hitPos)
		if distance < closestDistance then
			closest = i
			closestDistance = distance
		end
	end

	net.Start("Star_Trek.TransporterTool.Edit")
		net.WriteInt(closest, 32)
	net.Send(owner)
end

function TOOL:BuildCPanel()
	if SERVER then return end

	self:AddControl("Header", {
		Text = "#tool.external_transporter.name",
		Description = "Add a Name to your Location:"
	})

	textEntry = vgui.Create("DTextEntry")

	self:AddItem(textEntry)


end
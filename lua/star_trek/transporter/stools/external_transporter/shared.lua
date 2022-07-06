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

TOOL.Category = "ST:RP"
TOOL.Name = "External Transporter Location-Tool"
TOOL.ConfigName = ""

if (CLIENT) then
	language.Add("tool.external_transporter.name", "External Transporter Location-Tool")
	language.Add("tool.external_transporter.desc", "Allows placement of locations for the transporter. Every positions allows 7 people to beam down. Please leave enough space around them!")
	language.Add("tool.external_transporter.0", "Left-Click: Place Location, Right Click: Remove Closest Location")

	local externals = {}
	net.Receive("Star_Trek.TransporterTool.Sync", function()
		externals = net.ReadTable()
	end)

	local innerRadius = 5
	local outerRadius = 10
	local height = 30
	local function renderTransporterLocation(pos)
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
				renderTransporterLocation(externalData.Pos)
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

	function TOOL:Deploy()
		self:Sync()
	end
end

function TOOL:LeftClick(tr)
	if (CLIENT) then return true end

	local hitPos = tr.HitPos
	if not isvector(hitPos) then return end

	local externalData = {
		Name = name,
		Pos = hitPos
	}

	table.insert(Star_Trek.Transporter.Externals, externalData)

	hook.Run("Star_Trek.Transporter.ExternalsChanged")

	self:Sync()
end

function TOOL:RightClick(tr)
	if (CLIENT) then return true end

	local hitPos = tr.HitPos
	if not isvector(hitPos) then return end

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
		table.remove(Star_Trek.Transporter.Externals, id)

		hook.Run("Star_Trek.Transporter.ExternalsChanged")
	end

	self:Sync()
end
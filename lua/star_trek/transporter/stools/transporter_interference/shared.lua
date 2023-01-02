---------------------------------------
---------------------------------------
--         Star Trek Modules         --
--                                   --
--            Created by             --
--              Jarkyc               --
--                                   --
-- This software can be used freely, --
--    but only distributed by        --
--     Jan 'Oninoni' Ziegler.        --
--                                   --
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--    Server | Interference STool    --
---------------------------------------

if not istable(TOOL) then Star_Trek:LoadAllModules() return end

TOOL.Category = "ST:RP"
TOOL.Name = "Transporter Interference-Tool"
TOOL.ConfigName = ""
local sliderEntry
local typeof

if (CLIENT) then
	TOOL.Information = {
		{ name = "left" },
		{ name = "right" },
	}

	language.Add("tool.transporter_interference.name", "Transporter Interference-Tool")
	language.Add("tool.transporter_interference.desc", "Places down a point in which a interference-beacon is spawned, preventing transport in or out of the configured radius.")
	language.Add("tool.transporter_interference.left", "Place interference")
	language.Add("tool.transporter_interference.right", "Remove Closest interference")

	net.Receive("Star_Trek.interferenceTool.Create", function()
		local hitPos = net.ReadVector()

		net.Start("Star_Trek.interferenceTool.Create")
			net.WriteVector(hitPos)
			net.WriteFloat(sliderEntry:GetValue())
		   local option, _ = typeof:GetSelected() 
	        net.WriteString(option)
		net.SendToServer()
	end)

	local interferences = {}
	net.Receive("Star_Trek.interferenceTool.Sync", function()
		interferences = net.ReadTable()
	end)


	local function renderinterference(pos, radius)
	    render.DrawWireframeSphere(pos, radius, 32, 32, Color(255, 0, 0))
	end

	hook.Add( "HUDPaint", "Transporterinterference.Render", function()
	    local toolSwep = LocalPlayer():GetActiveWeapon()
	    if not IsValid(toolSwep) or toolSwep:GetClass() ~= "gmod_tool" then
	        return
	    end

	    local toolTable = LocalPlayer():GetTool()
	    if not istable(toolTable) or toolTable.Mode ~= "transporter_interference" then
	        return
	    end

	    cam.Start3D()
	        for _, interferenceData in pairs(interferences or {}) do
	            renderinterference(interferenceData.Pos, interferenceData.Radius)
	        end
	    cam.End3D()
	end )

end

if SERVER then

	util.AddNetworkString("Star_Trek.interferenceTool.Sync")
	function TOOL:Sync()
		net.Start("Star_Trek.interferenceTool.Sync")
			net.WriteTable(Star_Trek.Transporter.Interferences)
		net.Send(self:GetOwner())
	end

	util.AddNetworkString("Star_Trek.interferenceTool.Create")
	net.Receive("Star_Trek.interferenceTool.Create", function(len, ply)
	    local hitPos = net.ReadVector()
	    local radius = net.ReadFloat()
	    local option = net.ReadString()
	    local tool = ply:GetTool()
	    if tool.Mode ~= "transporter_interference" then return end

	    local interferenceData = {
	        Pos = hitPos, 
	        Radius = radius,
	        Type = option
	    }

	    table.insert(Star_Trek.Transporter.Interferences, interferenceData)

	    tool:Sync()
	end)

	function TOOL:Deploy()
		self:Sync()
	end
end

function TOOL:LeftClick( trace )

	if (CLIENT) then return true end

	local hitPos = trace.HitPos
	if not isvector(hitPos) then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return true end

	net.Start("Star_Trek.interferenceTool.Create")
		net.WriteVector(hitPos)
	net.Send(owner)

	self:Sync()
end

function TOOL:RightClick( trace )
	if (CLIENT) then return true end

	local hitPos = trace.HitPos
	if not isvector(hitPos) then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return true end

	local closest = nil
	local closestDistance = math.huge
	for i, interference in pairs(Star_Trek.Transporter.Interferences) do
	    local pos = interference.Pos 
	    local distance = pos:Distance(hitPos)
	    if distance < closestDistance then
	        closest = i
	        closestDistance = distance
	    end
	end

	if closest ~= nil then
	    table.remove(Star_Trek.Transporter.Interferences, closest)
	end

	self:Sync()
end

function TOOL:BuildCPanel(panel)
	if SERVER then return end

	self:AddControl("Header", {
		Text = "#tool.transporter_interference.name",
		Description = "Select the radius of your interference field:"
	})

	sliderEntry = vgui.Create("DNumSlider") 
	sliderEntry:SetMin(0)
	sliderEntry:SetMax(5000)
	sliderEntry:SetValue(1)

	self:AddItem(sliderEntry)

	self:AddControl("Header", {
		Text = "Interference Type",
		Description = "Select the type of interference"
	})

	typeof = vgui.Create("DComboBox")
	typeof:AddChoice("Unknown")
	typeof:AddChoice("Magnesite")
	typeof:AddChoice("Thoron Radiation")
	typeof:AddChoice("Dampening Field")
	typeof:AddChoice("Ionic")
	typeof:AddChoice("Hyperonic Radiation")
	typeof:AddChoice("Electromagnetic")
	typeof:AddChoice("Trinimbic")
    typeof:AddChoice("Shield")
	typeof:ChooseOptionID(1)

	self:AddItem(typeof)

end
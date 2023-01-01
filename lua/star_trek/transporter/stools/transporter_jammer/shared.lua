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
--     Server | Jammer STool         --
---------------------------------------

if not istable(TOOL) then Star_Trek:LoadAllModules() return end

TOOL.Category = "ST:RP"
TOOL.Name = "Transporter Jammer-Tool"
TOOL.ConfigName = ""
local sliderEntry

if (CLIENT) then
	TOOL.Information = {
		{ name = "left" },
		{ name = "right" },
	}

	language.Add("tool.transporter_jammer.name", "Transporter Jammer-Tool")
	language.Add("tool.transporter_jammer.desc", "Places down a point in which a jammer-beacon is spawned, preventing transport in or out of the configured radius.")
	language.Add("tool.transporter_jammer.left", "Place Jammer")
	language.Add("tool.transporter_jammer.right", "Remove Closest Jammer")

    net.Receive("Star_Trek.JammerTool.Create", function()
		local hitPos = net.ReadVector()

		net.Start("Star_Trek.JammerTool.Create")
			net.WriteVector(hitPos)
			net.WriteFloat(sliderEntry:GetValue())
		net.SendToServer()
	end)

    local jammers = {}
    net.Receive("Star_Trek.JammerTool.Sync", function()
		jammers = net.ReadTable()
	end)


    local function renderJammer(pos, radius)
        render.DrawWireframeSphere(pos, radius, 32, 32, Color(255, 0, 0))
    end

    hook.Add( "HUDPaint", "TransporterJammer.Render", function()
        local toolSwep = LocalPlayer():GetActiveWeapon()
        if not IsValid(toolSwep) or toolSwep:GetClass() ~= "gmod_tool" then
            return
        end

        local toolTable = LocalPlayer():GetTool()
        if not istable(toolTable) or toolTable.Mode ~= "transporter_jammer" then
            return
        end

        cam.Start3D()
            for _, jammerData in pairs(jammers or {}) do
                renderJammer(jammerData.Pos, jammerData.Radius)
            end
        cam.End3D()
    end )

end

if SERVER then

    util.AddNetworkString("Star_Trek.JammerTool.Sync")
	function TOOL:Sync()
		net.Start("Star_Trek.JammerTool.Sync")
			net.WriteTable(Star_Trek.Transporter.Jammers)
		net.Send(self:GetOwner())
	end

    util.AddNetworkString("Star_Trek.JammerTool.Create")
    net.Receive("Star_Trek.JammerTool.Create", function(len, ply)
        local hitPos = net.ReadVector()
        local radius = net.ReadFloat()

        local tool = ply:GetTool()
        if tool.Mode ~= "transporter_jammer" then return end

        local jammerData = {
            Pos = hitPos, 
            Radius = radius
        }

        table.insert(Star_Trek.Transporter.Jammers, jammerData)

        tool:Sync()
    
    end)

    function TOOL:Deploy()
		self:Sync()
	end
end

function TOOL:LeftClick( trace )
    print("Left click")

    if (CLIENT) then return true end

	local hitPos = trace.HitPos
	if not isvector(hitPos) then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return true end

	net.Start("Star_Trek.JammerTool.Create")
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

    print("Right Click")
    for i, jammer in pairs(Star_Trek.Transporter.Jammers) do
        local pos = jammer.Pos 
        local distance = pos:Distance(hitPos)
        if distance < closestDistance then
            closest = i
            closestDistance = distance
        end
    end

    if closest ~= nil then
        table.remove(Star_Trek.Transporter.Jammers, closest)
    end

    self:Sync()
end

function TOOL:BuildCPanel(panel)
    if SERVER then return end

    self:AddControl("Header", {
		Text = "#tool.transporter_jammer.name",
		Description = "Select the radius of your jammer field:"
	})

    sliderEntry = vgui.Create("DNumSlider") 
    sliderEntry:SetMin(0)
    sliderEntry:SetMax(5000)
    sliderEntry:SetValue(1)

    self:AddItem(sliderEntry)
end
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
--           PADD | Server           --
---------------------------------------

util.AddNetworkString("Star_Trek.PADD.Enable")
util.AddNetworkString("Star_Trek.PADD.Disable")

function Star_Trek.PADD:Enable(padd, interfaceName)
	if padd.Enabled then
		return false, "PADD Already Active"
	end

	local ply = padd:GetOwner()
	if not IsValid(ply) then
		return false, "Invalid Owner"
	end

	net.Start("Star_Trek.PADD.Enable")
	net.Send(ply)

	padd.Enabled = true

	return true
end

function Star_Trek.PADD:Disable(padd)
	if not padd.Enabled then
		return false, "PADD Already Inactive"
	end

	local ply = padd:GetOwner()
	if not IsValid(ply) then
		return false, "Invalid Owner"
	end

	net.Start("Star_Trek.PADD.Disable")
	net.Send(ply)

	padd.Enabled = false

	return true
end

function Star_Trek.PADD:LoadInterfaces()
	local _, directories = file.Find("star_trek/padd/interfaces/*", "LUA")

	for _, interfaceName in pairs(directories) do
		INTERFACE = {}

		include("interfaces/" .. interfaceName .. "/init.lua")

		self.Interfaces[interfaceName] = INTERFACE
		INTERFACE = nil

		Star_Trek:Message("Loaded PADD Interface \"" .. interfaceName .. "\"")
	end
end

--Star_Trek.PADD:LoadInterfaces()
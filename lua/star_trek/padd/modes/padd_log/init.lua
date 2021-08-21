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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--   LCARS SWEP Mode: Logs | Server  --
---------------------------------------

MODE.BaseMode = "base"

MODE.Name = "Logs"
MODE.MenuColor = Star_Trek.LCARS.ColorBlue

function MODE:CanActivate(ent)
	return true
end

function MODE:Activate(ent)
	local ply = ent:GetOwner()
	if not IsValid(ply) then
		return false, "Invalid Owner"
	end

	Star_Trek.LCARS:OpenInterface(ply, ent, "padd_log", self.Title, self.LogData)

	return true
end

function MODE:Deactivate(ent, callback)
	if istable(ent.Interface) then
		self.Title, self.LogData = ent.Interface:GetData()

		ent.Interface:Close(callback)
		return true
	end

	callback()
	return true
end

function MODE:PrimaryAttack(ent)
	if not istable(ent.Interface) then return end

	local ply = ent:GetOwner()
	if not IsValid(ply) then return end

	local targetEnt = ply:GetEyeTrace().Entity
	if not IsValid(targetEnt) then return end

	local data = targetEnt.LastData or {}
	if istable(targetEnt.Interface) and isfunction(targetEnt.Interface.GetData) then
		data = targetEnt.Interface:GetData()
	end

	if data and data.LogData then
		ent.Interface:SetData((data.LogTitle or "Generic") .. " Logs", data.LogData)
	end
end

function MODE:SecondaryAttack(ent)
	-- TODO: Upload to Screen
end
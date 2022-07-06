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
--          Button | Server          --
---------------------------------------

-- Creates a button with a given callback.
--
-- @param Vector pos
-- @param Angle ang
-- @param String model
-- @param Function callback(ent, ply)
-- @param Boolean strict
-- @return Boolean success
-- @return? String error
function Star_Trek.Button:CreateButton(pos, ang, model, callback, strict)
	local ent = ents.Create("gmod_button")
	ent.StarTrekButton = true

	ent:SetPos(pos)
	ent:SetAngles(ang)

	ent:SetModel(model)
	ent:Spawn()

	if not strict then
		ent:SetNoDraw(true)
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end

	local phys = ent:GetPhysicsObject()
	if phys then
		phys:EnableMotion(false)
	end

	function ent:Use(activator, caller, type, value)
		if not IsValid(activator) or not activator:IsPlayer() then
			return
		end

		if type == USE_ON and isfunction(callback) then
			callback(self, activator)
		end
	end

	return true, ent
end

-- Creates a button, that opens a given interface.
-- @param Vector pos
-- @param Angle ang
-- @param String model
-- @param String interfaceName
-- @param Boolean strict
-- @return Boolean success
-- @return? String error
function Star_Trek.Button:CreateInterfaceButton(pos, ang, model, interfaceName, strict)
	if not isstring(interfaceName) then
		return false, "Interface Type Invalid"
	end

	local success, ent = self:CreateButton(pos, ang, model, function(ent, ply)
		local success2, error2 = Star_Trek.LCARS:OpenInterface(ply, ent, interfaceName)
		if not success2 then
			print("Callback Error: ", error2)
			return
		end
	end, strict)

	if not success then
		return false, ent
	end

	return true, ent
end

-- Prevent Viewscreen from being picked up by a Physgun
hook.Add("PhysgunPickup", "Star_Trek.Button.PreventPickup", function(ply, ent)
	if ent.StarTrekButton then
		return false
	end
end)

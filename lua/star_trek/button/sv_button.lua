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
-- @param Vector size
-- @param Function callback(ent, ply)
-- @return Boolean success
-- @return? String error
function Star_Trek.Button:CreateButton(pos, ang, model, callback)
	local ent = ents.Create("gmod_button")

	ent:SetPos(pos)
	ent:SetAngles(ang)

	ent:SetModel(model)
	ent:Spawn()

	ent:SetNoDraw(true)
	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	local phys = ent:GetPhysicsObject()
	if phys then
		phys:EnableMotion(false)
	end

	function ent:Use(activator, caller, type, value)
		if not IsValid(activator) or not activator:IsPlayer() then
			return
		end

		if type == USE_ON then
			callback(self, activator)
		end
	end

	return true, ent
end

-- Creates a button, that opens a given interface.
-- @param Vector pos
-- @param Angle ang
-- @param Vector size
-- @param String interfaceName
-- @return Boolean success
-- @return? String error
function Star_Trek.Button:CreateInterfaceButton(pos, ang, size, interfaceName)
	if not isstring(interfaceName) then
		return false, "Interface Type Invalid"
	end

	local success, ent = self:CreateButton(pos, ang, size, function(ent, ply)
		local success2, error2 = Star_Trek.LCARS:OpenInterface(ply, ent, interfaceName)
		if not success2 then
			print("Callback Error: ", error2)
			return
		end
	end)

	if not success then
		return false, ent
	end

	return true, ent
end
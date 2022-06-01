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
--     Transporter Pads | Shared     --
---------------------------------------

function Star_Trek.Transporter:ApplyPadEffect(transporterCycle, sourcePad, targetPad)
	local state = transporterCycle.State
	if state == 1 then
		if IsValid(sourcePad) then
			sourcePad:SetSkin(1)
		end
	elseif state == 2 then
		if IsValid(sourcePad) then
			sourcePad:SetSkin(0)
		end
	elseif state == 3 then
		if IsValid(targetPad) then
			targetPad:SetSkin(1)
		end
	elseif state == 4 then
		if IsValid(targetPad) then
			targetPad:SetSkin(0)
		end
	end
end

function Star_Trek.Transporter:GetPadPosition(ent)
	local overridePos = hook.Run("Star_Trek.Transporter.GetPadPosition", ent)
	if isvector(overridePos) then
		return overridePos
	end

	local pos = ent:GetPos()
	local attachmentId = ent:LookupAttachment("teleportPoint")
	if attachmentId > 0 then
		pos = ent:GetAttachment(attachmentId).Pos
	end

	return pos
end

function Star_Trek.Transporter:IsCargoPad(ent)
	local override = hook.Run("Star_Trek.Transporter.IsCargoPad", ent)
	if override ~= nil then
		return override
	end

	if ent:GetModel() == "models/kingpommes/startrek/intrepid/transporter_cargopad.mdl" then
		return true
	end

	return false
end
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
--   LCARS Bridge Security | Server  --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

SELF.BaseInterface = "base"

SELF.LogType = false

function SELF:Open(ent)
	local success1, codeWindow = Star_Trek.LCARS:CreateWindow(
		"keypad",
		Vector(0, 0, 0),
		Angle(0, 0, 0),
		25,
		350,
		310,
		function(windowData, interfaceData, ply, values)
			local coreBut1 = ents.FindByName("coreBut1")[1]

			local code = table.concat(values)
			if Star_Trek.WarpCore:IsValidCode(code) then
				interfaceData:Close()

				coreBut1:Fire("FireUser3")
				Star_Trek.Logs:AddEntry(coreBut1, ply, "")
				Star_Trek.Logs:AddEntry(coreBut1, ply, "Warp Core ejected!")

				Star_Trek.Logs:AddEntry(coreBut1, ply, "Code Used:")
				local codeName = table.KeyFromValue(Star_Trek.WarpCore.ValidCodes, code)
				Star_Trek.Logs:AddEntry(coreBut1, ply, codeName)
			else
				interfaceData.Ent:EmitSound("star_trek.lcars_error")

				Star_Trek.Logs:AddEntry(coreBut1, ply, "")
				Star_Trek.Logs:AddEntry(coreBut1, ply, "Invalid Security Code!")
			end
		end,
		"Enter Security Code",
		"CODE",
		true
	)
	if not success1 then
		return false, codeWindow
	end

	return true, {codeWindow}
end
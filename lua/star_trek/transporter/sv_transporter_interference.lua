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
-- Transporter Interference | Server --
---------------------------------------

Star_Trek.Transporter.Interferences = Star_Trek.Transporter.Interferences or {}

hook.Add("Star_Trek.Transporter.BlockBeamTo", "Star_Trek.Transporter.CheckForInterfereneces", function(pos)
    for _, data in pairs(Star_Trek.Transporter.Interferences) do
        interferencePos = data.Pos
        interferenceRadius = data.Radius
        distance = pos:Distance(interferencePos)
        -- Check dist and if the interference should be ignored. If the hook returns true, then yes.
        if distance <= interferenceRadius and not hook.Run("Star_Trek.Transporter.IgnoreInterference", data, pos) then
            return true, "Unabled to lock onto target. " .. data.Type .. " Interference detected."
        end
    end
end)
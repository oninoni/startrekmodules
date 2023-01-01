Star_Trek.Transporter.Interferences = Star_Trek.Transporter.Interferences or {} 

hook.Add("Star_Trek.Transporter.BlockBeamTo", "Star_Trek.Transporter.CheckForInterfereneces", function(pos)
    for _, data in pairs(Star_Trek.Transporter.Interferences) do
        interferencePos = data.Pos
        interferenceRadius = data.Radius  
        distance = pos:Distance(interferencePos)
        if distance <= interferenceRadius then
            return true, "Unabled to lock onto target. Interference detected."
        end
    end
end)
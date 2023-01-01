Star_Trek.Transporter.Inhibitors = Star_Trek.Transporter.Inhibitors or {} 

hook.Add("Star_Trek.Transporter.BlockBeamTo", "Star_Trek.Transporter.CheckForInhibitors", function(pos)
    for _, data in pairs(Star_Trek.Transporter.Inhibitors) do
        inhibitorPos = data.Pos
        inhibitorRadius = data.Radius  
        distance = pos:Distance(inhibitorPos)
        if distance <= inhibitorRadius then
            return true, "Unabled to lock onto target. Interference detected."
        end
    end
end)
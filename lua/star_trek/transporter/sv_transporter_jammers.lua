Star_Trek.Transporter.Jammers = Star_Trek.Transporter.Jammers or {} 

hook.Add("Star_Trek.Transporter.BlockBeamTo", "Star_Trek.Transporter.CheckForceJammers", function(pos)
    for _, data in pairs(Star_Trek.Transporter.Jammers) do
        jammerPos = data.Pos
        jammerRadius = data.Radius  
        distance = pos:Distance(jammerPos)
        if distance <= jammerRadius then
            return true, "Unabled to lock onto target. Interference detected."
        end
    end
end)
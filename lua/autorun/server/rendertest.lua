
function LCARS:SpawnPortal(id)
    local ply = player.GetAll()[1]
    local trace = ply:GetEyeTrace()
    if not trace.Hit then return end

    local pos = trace.HitPos 
    
    local ent = ents.GetByIndex(id)
    if not IsValid(ent) then return end

    local window = ents.Create("linked_portal_window")
    window:SetPos(pos)

    window:SetWidth(400)
    window:SetHeight(300)

    window:SetExit(ent)
    
    window:Spawn()
    window:Activate()
end

--timer.Create("Testing", 0, 0, function()
--    ents.GetAll()[181]:SetAngles(ents.GetAll()[181]:GetAngles() + Angle(0,0.2,0))
--end)
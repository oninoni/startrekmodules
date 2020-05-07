util.AddNetworkString("LCARS.FlyShip")
net.Receive("LCARS.FlyShip", function(len, ply)
    local data = net.ReadTable()
    ply.FlyData = data
end)

hook.Add("Think", "LCARS.FlyShipThink", function()
    if not IsValid(LCARS.ConnSeat) then
        local entities = ents.FindByName("connSeat")
        if IsValid(entities[1]) then
        	LCARS.ConnSeat = entities[1]
        end
    end
    
    local ply = LCARS.ConnSeat:GetDriver()
    if IsValid(ply) and ply:IsPlayer() then
        local data = ply.FlyData

        local ent = ents.FindByName("skybox_3")[1]

        local a = ent:GetAngles()
        if data[KEY_A] then
            ent:SetAngles(a + Angle(0, 0.2, 0))
        elseif data[KEY_D] then
            ent:SetAngles(a - Angle(0, 0.2, 0))
        end

        local v = ent:GetPos()
        if data[KEY_W] then
            ent:SetPos(v + Vector(0, 0, 1))
        elseif data[KEY_S] then
            ent:SetPos(v - Vector(0, 0, 1))
        end
    end
end)
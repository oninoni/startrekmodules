local pressedKeys = {
    [KEY_W] = false,
    [KEY_A] = false,
    [KEY_S] = false,
    [KEY_D] = false,
}

hook.Add("Think", "Test", function()
    local ply = LocalPlayer()
    local veh = ply:GetVehicle()
    if IsValid(veh) then
        if veh:GetModel() ~= "models/kingpommes/startrek/voyager/seat_officechair_b.mdl" then return end

        local changed = false
        for key, value in pairs(pressedKeys) do
            local newValue = input.IsKeyDown(key)
            if newValue ~= value then
                changed = true
                pressedKeys[key] = newValue
            end
        end

        if changed then
            net.Start("LCARS.FlyShip")
                net.WriteTable(pressedKeys)
            net.SendToServer()
        end
    end
end)
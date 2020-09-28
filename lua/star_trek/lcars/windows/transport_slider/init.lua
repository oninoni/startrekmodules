function WINDOW.OnCreate(windowData)
    return windowData
end

function WINDOW.OnPress(windowData, interfaceData, ent, buttonId, callback)
    ent:EmitSound("buttons/blip1.wav")
    -- TODO: Replace Sound

    callback(windowData, interfaceData, ent, buttonId)
end
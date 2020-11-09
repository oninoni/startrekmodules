function WINDOW.OnCreate(windowData)
    return windowData
end

function WINDOW.OnPress(windowData, interfaceData, ent, buttonId, callback)
    ent:EmitSound("star_trek.lcars_transporter_lock")

    callback(windowData, interfaceData, ent, buttonId)
end
function WINDOW:OnCreate()
	return self
end

function WINDOW:OnPress(interfaceData, ent, buttonId, callback)
	ent:EmitSound("star_trek.lcars_transporter_lock")

	callback(windowData, interfaceData, ent, buttonId)
end
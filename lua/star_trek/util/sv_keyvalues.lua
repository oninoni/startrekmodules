-- Capture all Keyvalues so they can be read when needed.
hook.Add("EntityKeyValue", "LCARS.CaptureKeyValues", function(ent, key, value)
    ent.LCARSKeyData = ent.LCARSKeyData or {}

    if string.StartWith(key, "lcars") then
        ent.LCARSKeyData[key] = value

		hook.Run("LCARS.ChangedKeyValue", ent, key, value)
    end
end)

-- Capture Live Changes to lcars convars.
hook.Add("AcceptInput", "LCARS.CaptureKeyValuesLive", function(ent, input, activator, caller, value)
    if input ~= "AddOutput" then return end

    local valueSplit = string.Split(value, " ")
    local key = valueSplit[1]
    if string.StartWith(key, "lcars") then
    	ent.LCARSKeyData = ent.LCARSKeyData or {}

		local realValue = ""
		for i, splitString in pairs(valueSplit) do
			if i == 1 then continue end
			realValue = realValue .. splitString
			if i ~= #valueSplit then 
				realValue = realValue .. " "
			end
		end
        ent.LCARSKeyData[key] = realValue

		hook.Run("LCARS.ChangedKeyValue", ent, key, realValue)
    end
end)

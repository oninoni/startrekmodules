local detectMapStrings = {
	"rp_voyager",
	"rp_intrepid_v",
	"rp_intrepid_dev_v",
}
local skip = true
for _, mapString in pairs(detectMapStrings) do
	if string.StartWith(game.GetMap(), mapString) then
		skip = false
		continue
	end
end

if skip then return end

if SERVER then 
	AddCSLuaFile()
end

if CLIENT then
	RunConsoleCommand( "mat_specular", "1")
	RunConsoleCommand( "mat_hdr_level", "2" )
end
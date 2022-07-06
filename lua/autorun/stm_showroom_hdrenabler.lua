---------------------------------------
---------------------------------------
--         Star Trek Modules         --
--                                   --
--            Created by             --
--       Jan 'Oninoni' Ziegler       --
--                                   --
-- This software can be used freely, --
--    but only distributed by me.    --
--                                   --
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--         Star Trek | Loader        --
---------------------------------------

if not string.StartWith(game.GetMap(), "stm_showroom") then return end

if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	RunConsoleCommand( "mat_specular", "1")

	local convar = GetConVar("mat_hdr_level")
	if convar:GetInt() ~= 2 then
		chat.AddText("Invalid HDR Setup Detected. Restarting Map with HDR Active!")
		chat.AddText("In multiplayer you will have to re-join the server!")

		timer.Simple(1, function()
			RunConsoleCommand( "mat_hdr_level", "2" )
		end)
	end
end

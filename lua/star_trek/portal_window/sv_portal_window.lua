
-- Add all portal visleafs to server's potentially visible set
hook.Add( "SetupPlayerVisibility", "WorldPortals_AddPVS", function( ply, ent )
	for _, portal in ipairs( ents.FindByClass( "linked_portal_window" ) ) do
		local exit = portal:GetExit()
		if IsValid(exit) then
			AddOriginToPVS( exit:GetPos() )
		end
	end
end )
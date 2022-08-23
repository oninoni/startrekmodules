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
--   Linked Portal Window | Client   --
---------------------------------------

if not istable(ENT) then Star_Trek:LoadAllModules() return end

ENT.Type				= "anim"
ENT.RenderGroup			= RENDERGROUP_BOTH -- fixes translucent stuff rendering behind the portal
ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.Editable			= false

function ENT:Initialize()
	local mins = Vector( 0, -self:GetWidth() / 2, -self:GetHeight() / 2 )
	local maxs = Vector( 10, self:GetWidth() / 2, self:GetHeight() / 2)

	if CLIENT then

		self:SetTexture( GetRenderTarget("portal" .. self:EntIndex(),
			ScrW(),
			ScrH(),
			false
		) )

		self:SetRenderBounds( mins, maxs )

	else

		self:SetTrigger( true )

	end

	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_OBB )
	--self:SetNotSolid( true )
	self:SetCollisionBounds( mins, maxs )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )

	self:DrawShadow( false )
end

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "Exit" )
	self:NetworkVar( "Int", 1, "Width" )
	self:NetworkVar( "Int", 2, "Height" )
	self:NetworkVar( "Int", 3, "DisappearDist" )
	self:NetworkVar( "Int", 4, "Scale")

	self:NetworkVar( "Vector", 0, "ExitPosOffset" )
	self:NetworkVar( "Angle", 0, "ExitAngOffset" )
end
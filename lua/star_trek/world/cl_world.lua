---------------------------------------
---------------------------------------
--        Star Trek Utilities        --
--                                   --
--            Created by             --
--       Jan 'Oninoni' Ziegler       --
--                                   --
-- This software can be used freely, --
--    but only distributed by me.    --
--                                   --
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--           World | Client          --
---------------------------------------

local SKY_CAM_SCALE = Star_Trek.World.Skybox_Scale

function Star_Trek.World:AddObject(i, pos, ang, scale, model, fullbright)
	local obj = {
		Pos = pos,
		Ang = ang,
		Scale = SKY_CAM_SCALE * scale,
		FullBright = fullbright,
	}

	ent = ClientsideModel(model)
	ent:SetNoDraw(true)

	local modelScale = ent:GetModelBounds()
	print(modelScale)

	ent:SetModelScale(obj.Scale)
	ent.Scale = obj.Scale

	obj.Ent = ent

	self.Objects[i] = obj
end

function Star_Trek.World:UpdateObject(i, pos, ang)
	local obj = self.Objects[i]

	obj.Pos = pos
	obj.Ang = ang
end

function Star_Trek.World:RemoveObject(i)
	local obj = self.Objects[i]
	obj.Ent:Remove()

	self.Objects[i] = nil
end

function Star_Trek.World:GetShipPos()
	return self.ShipPos, self.ShipAng
end

function Star_Trek.World:SetShipPos(pos, ang)
	self.ShipPos = pos or Vector()
	self.ShipAng = ang or Angle()
end

hook.Add("PostDraw2DSkyBox", "Star_Trek.Testing", function()
	Star_Trek.World:Draw()
end)

Star_Trek.World:SetShipPos(Vector(0, 0, 0), Angle())

--[[
10^10 Skybox Units
1024 * 10^10 Skybo Units
195.084.778.052 Meter
    696.000.000 Meter
~ Bissl mehr als 1 AU
63.241 AU = 1 LJ
~206.000 AU = 1Parsec
100.000 LJ = Milchstraße (Max Map Size)

2 Units, 

1. Unitsx1024
2. Astronomic Unit

Max Value Jeweils
1. ~10^10
2. 6.342.100.000 (~10^10)


Feinheit Test:
32 Bit

1 Bit Sign
]]

function Star_Trek.World:ConvertFromMeter(value)
	local units = 52.49 * value
	return units / 1024
end

debugoverlay.Line(Vector(0, 0, 0), 52.49 * (Vector(100, 0, 0)), 10, Color(255,0,0), true)

debugoverlay.Line(Vector(0, 0, 0), 52.49 * (Vector(-100, 0, 0)), 10, Color(0,255,0), true)

--Star_Trek.World:AddObject(1, Vector(Star_Trek.World:ConvertFromMeter(149597870700), 0, 0), Angle(0, 0, 0), Star_Trek.World:ConvertFromMeter(696342000), "models/sb_genesis_omega/planet2.mdl", true)

local distance = 150000000000
local radius = 690000000

Star_Trek.World:AddObject(1, Vector(Star_Trek.World:ConvertFromMeter(distance), 0, 0), Angle(0, 0, 0), Star_Trek.World:ConvertFromMeter(radius) / (2620 / 1024), "models/sb_genesis_omega/planet2.mdl", true)
--Star_Trek.World:AddObject(2, Vector(3000, 0, 2000), Angle(0, 90, -90), 512, "models/sb_genesis_omega/planet2.mdl", true)

--[[
Star_Trek.World:AddObject(3, Vector(0, 25, 0), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(4, Vector(0, 25, 0), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(5, Vector(0, -25, 0), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(6, Vector(0, -25, 0), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(7, Vector(0, 25, 25), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(8, Vector(0, 25, 25), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(9, Vector(0, -25, 25), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(10, Vector(0, -25, 25), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(11, Vector(0, 25, -25), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(12, Vector(0, 25, -25), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(13, Vector(0, -25, -25), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(14, Vector(0, -25, -25), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(15, Vector(0, 0, -25), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(16, Vector(0, 0, -25), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(17, Vector(0, 0, 25), Angle(), 6, "models/apwninthedarks_starship_pack/enterprise-e.mdl")
Star_Trek.World:AddObject(18, Vector(0, 0, 25), Angle(), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")

Star_Trek.World:AddObject(50, Vector(0, 0, 6), Angle(0, 0, 180), 5, "models/apwninthedarks_starship_pack/drydock_type_4.mdl")
]]

local startTime = SysTime()
local SPEED = 0

hook.Add("Think", "Testing", function()
	local time = SysTime() - startTime

	--local speed = (Star_Trek.World.Objects[1].Pos):Length() * SPEED * (time / 10)

	--Star_Trek.World:SetShipPos(Vector(-(time * time) * SPEED, 0, 4))

--	Star_Trek.World:UpdateObject(1, Vector(3000 + time * speed, 5000, 0), Angle())
--	Star_Trek.World:UpdateObject(3, Vector(0 + time * speed, 25, 0), Angle())
--	Star_Trek.World:UpdateObject(4, Vector(0 + time * speed, 25, 0), Angle())
end)
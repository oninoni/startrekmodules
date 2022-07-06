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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--       World Render | Client       --
---------------------------------------

-- Vector_Max in Skybox is  (2^17) 
-- @ x1024 (2^10) Scale -> Visually at 134217728 (2^27)
local VECTOR_MAX = 131071 -- TODO: Recheck

local SKY_CAM_SCALE = Star_Trek.World.Skybox_Scale

local shipPos, shipAng
function Star_Trek.World:RenderThink()
	shipPos, shipAng = Star_Trek.World:GetShipPos()
	if not shipPos then return end

	--TODO: Optimise + Sorting

	for _, ent in ipairs(self.Entities) do
		if CLIENT then
			local pos, ang = WorldToLocalBig(ent.Pos, ent.Ang, shipPos, shipAng)

			local realEnt = ent.ClientEntity

			-- Apply scaling
			local modelScale = ent.Scale or 1
			local distance = pos:Length()
			if distance > VECTOR_MAX then
				pos = Vector(pos)
				pos:Normalize()

				pos = pos * VECTOR_MAX
				realEnt:SetModelScale(modelScale * (VECTOR_MAX / distance))
			else
				realEnt:SetModelScale(modelScale)
			end

			realEnt:SetPos(pos)
			realEnt:SetAngles(ang)
		end
	end
end

local eyePos, eyeAngles
hook.Add("PreDrawSkyBox", "Star_Trek.World.Draw", function()
	eyePos, eyeAngles = EyePos(), EyeAngles()
end)

function Star_Trek.World:Draw()
	if not shipPos then return end

	render.SuppressEngineLighting(true)
	cam.IgnoreZ(true)

	local mat = Matrix()
	mat:SetAngles(shipAng)
	mat:Rotate(eyeAngles)

	cam.Start3D(Vector(), mat:GetAngles(), nil, nil, nil, nil, nil, 0.5, 2)
		self:DrawBackground()
	cam.End3D()

	cam.Start3D(eyePos * SKY_CAM_SCALE, eyeAngles, nil, nil, nil, nil, nil, 0.0005, 10000000)
		for i, ent in ipairs(self.Entities) do
			if i == 1 then continue end

			ent.ClientEntity:DrawModel()
		end
	cam.End3D()

	cam.IgnoreZ(false)
	render.SuppressEngineLighting(false)
end

hook.Add("PostDraw2DSkyBox", "Star_Trek.World.Draw", function()
	Star_Trek.World:Draw()
end)
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
--     Backgroud Render | Client     --
---------------------------------------

local skyCorners = {
	Vector( 1,  1,  1),
	Vector( 1,  1, -1),
	Vector( 1, -1,  1),
	Vector( 1, -1, -1),
	Vector(-1,  1,  1),
	Vector(-1,  1, -1),
	Vector(-1, -1,  1),
	Vector(-1, -1, -1),
}
local skyMaterials = {
	Material("skybox/sky_intrepidft"),
	Material("skybox/sky_intrepidbk"),
	Material("skybox/sky_intrepidrt"),
	Material("skybox/sky_intrepidlf"),
	Material("skybox/sky_intrepidup"),
	Material("skybox/sky_intrepiddn"),
}
function Star_Trek.World:DrawBackground()
	render.SetMaterial(skyMaterials[1])
	render.DrawQuad(
		skyCorners[3],
		skyCorners[7],
		skyCorners[8],
		skyCorners[4])

	render.SetMaterial(skyMaterials[2])
	render.DrawQuad(
		skyCorners[5],
		skyCorners[1],
		skyCorners[2],
		skyCorners[6])

	render.SetMaterial(skyMaterials[3])
	render.DrawQuad(
		skyCorners[1],
		skyCorners[3],
		skyCorners[4],
		skyCorners[2])

	render.SetMaterial(skyMaterials[4])
	render.DrawQuad(
		skyCorners[7],
		skyCorners[5],
		skyCorners[6],
		skyCorners[8])

	render.SetMaterial(skyMaterials[5])
	render.DrawQuad(
		skyCorners[5],
		skyCorners[7],
		skyCorners[3],
		skyCorners[1])

	render.SetMaterial(skyMaterials[6])
	render.DrawQuad(
		skyCorners[2],
		skyCorners[4],
		skyCorners[8],
		skyCorners[6])
end

local xNormal = Vector(1, 0, 0)
local yNormal = Vector(0, 1, 0)
local zNormal = Vector(0, 0, 1)

local backgroundOffset = 1024 * 16
local backgroundSize = backgroundOffset * 2

local xOffset = xNormal * backgroundOffset
local yOffset = yNormal * backgroundOffset
local zOffset = zNormal * backgroundOffset

local backgroundColor = Color(0, 0, 0)

local frontMaterial = Material("skybox/sky_venatorft", "")
local backMaterial = Material("skybox/sky_venatorbk", "")

local leftMaterial = Material("skybox/sky_venatorlf", "")
local rightMaterial = Material("skybox/sky_venatorrt", "")

local downMaterial = Material("skybox/sky_venatordn", "")
local upMaterial = Material("skybox/sky_venatorup", "")

local function RenderBackground()
	local matrix = Matrix()
    matrix:Translate(LocalPlayer():EyePos())

    cam.PushModelMatrix(matrix)
        render.SetMaterial(rightMaterial)
        render.DrawQuadEasy(xOffset, -xNormal, backgroundSize, backgroundSize, backgroundColor, 180)
        render.SetMaterial(leftMaterial)
        render.DrawQuadEasy(-xOffset, xNormal, backgroundSize, backgroundSize, backgroundColor, 180)
        
        render.SetMaterial(backMaterial)
        render.DrawQuadEasy(yOffset, -yNormal, backgroundSize, backgroundSize, backgroundColor, 180)
        render.SetMaterial(frontMaterial)
        render.DrawQuadEasy(-yOffset, yNormal, backgroundSize, backgroundSize, backgroundColor, 180)
        
        render.SetMaterial(upMaterial)
        render.DrawQuadEasy(zOffset, -zNormal, backgroundSize, backgroundSize, backgroundColor, 0)
        render.SetMaterial(downMaterial)
        render.DrawQuadEasy(-zOffset, zNormal, backgroundSize, backgroundSize, backgroundColor, 0)
    cam.PopModelMatrix()
end

local trails = {}
local function RenderWarpTrails()
    local toBeRemoved = {}
    for i, trail in pairs(trails) do

        trail.Offset = trail.Offset + 10 * FrameTime()
        if trail.Offset > 10 then
            table.insert(toBeRemoved, i)
        end

        render.DrawLine(Vector(-trail.Offset, trail.X, trail.Y) * 10, Vector(-trail.Offset + 10, trail.X, trail.Y) * 10, Color(255, 255, 255), false)
    end
    for _, i in pairs(toBeRemoved) do
        table.remove(trails, i)
    end
    
    table.insert(trails, {
        Offset = -100,
        X = math.random(-20, 20),
        Y = math.random(-20, 20),
    })
end

--[[
hook.Add("PostDrawTranslucentRenderables", "LCARS.Rendertest", function(bDrawingDepth, bDrawingSkybox )
    if not OVERRIDESTUFF then return end

    --RenderBackground()

    --render.SetColorMaterialIgnoreZ()
    --RenderWarpTrails()
    
    --render.DrawSphere(Vector(0, 0, 0), 1000, 8, 8, Color(255, 255, 255))
end)
]]

hook.Add("wp-prerender", "LCARS.Viewscreen.PreRender", function(portal, exitPortal, plyOrigin)
	if portal:GetClass() ~= "linked_portal_window" then return end

	OVERRIDESTUFF = true
end)

hook.Add("wp-postrender", "LCARS.Viewscreen.PostRender", function(portal, exitPortal, plyOrigin)
	if portal:GetClass() ~= "linked_portal_window" then return end

	OVERRIDESTUFF = nil
end)
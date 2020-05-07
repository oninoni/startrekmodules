hook.Add("PostDrawOpaqueRenderables", "DrawShield", function()
	local mat = Matrix()
    mat:Scale(Vector(1, 0.5, 0.22))
    cam.PushModelMatrix(mat)
    
    render.SetColorMaterial()
    render.DrawSphere(Vector(2250, 0, -5500), 8000, 64, 64, Color(0, 127, 255, 7))
    
    cam.PopModelMatrix()
end)
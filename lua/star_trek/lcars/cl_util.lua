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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--        LCARS Util | Client        --
---------------------------------------

function Star_Trek.LCARS:GetInterfacePosAngle(ent, pos, ang)
	if IsValid(ent) then
		local oPos, oAng = hook.Run("Star_Trek.LCARS.OverridePosAng", ent, pos, ang)
		if isvector(oPos) and isangle(oAng) then
			return oPos, oAng
		end

		pos, ang = LocalToWorld(pos, ang, ent:GetPos(), ent:GetAngles())
	end

	return pos, ang
end

-- Calculate the ammount of scroll/offset of a button list.
--
-- @param Number listOffset
-- @param Number listHeight
-- @param Number buttonCount
-- @param Number mouseYPos
-- @return Number offset
function Star_Trek.LCARS:GetButtonOffset(listOffset, listHeight, buttonHeight, buttonCount, mouseYPos)
	local maxCount = math.floor(listHeight / buttonHeight) - 1

	local offset = listOffset
	if buttonCount > maxCount then
		local overFlow = math.min(0, listHeight - buttonCount * buttonHeight + 4)

		local relativePos = (mouseYPos - (listOffset + buttonHeight)) / (listHeight - buttonHeight * 2)
		offset = listOffset + relativePos * overFlow

		offset = math.min(offset, listOffset)
		offset = math.max(offset, listOffset + overFlow)
	end

	return offset
end

-- Generates the offset of a single button.
-- @param Number listHeight
-- @param Number i
-- @param Number buttonCount
-- @param Number offset
-- @return Number yPos
function Star_Trek.LCARS:GetButtonYPos(listHeight, buttonHeight, i, buttonCount, offset)
	local y = (i - 1) * (buttonHeight + 2) + offset

	return y
end

-- Drawing a circle using the given ammount of segments.
--
-- @param Number x
-- @param Number y
-- @param Number radius
-- @param Number seg
-- @param Color color
function Star_Trek.LCARS:DrawCircle(x, y, radius, seg, color)
	local cir = {}

	table.insert(cir, {x = x, y = y})
	for i = 0, seg do
		local arc = math.rad((i / seg) * -360)
		table.insert(cir, {x = x + math.sin( arc ) * radius, y = y + math.cos( arc ) * radius})
	end
	table.insert(cir, {x = x, y = y})

	surface.SetDrawColor(color)
	draw.NoTexture()
	surface.DrawPoly(cir)
end

function Star_Trek.LCARS:FilterMaterialSize(value)
	return 2 ^ math.ceil(math.log(value) / math.log(2))
end

function Star_Trek.LCARS:CreateMaterial(id, width, height, renderFunction)
	tWidth = Star_Trek.LCARS:FilterMaterialSize(width)
	tHeight = Star_Trek.LCARS:FilterMaterialSize(height)

	local textureName = "LCARS_" .. id .. "_" .. tWidth .. "X" .. tHeight
	local texture = GetRenderTarget(textureName, tWidth, tHeight)

	local oldW, oldH = ScrW(), ScrH()
	render.SetViewPort(0, 0, tWidth, tHeight)

	render.PushRenderTarget(texture)
	cam.Start2D()
		render.Clear(0, 0, 0, 0, true, true)

		renderFunction()
	cam.End2D()
	render.PopRenderTarget()

	render.SetViewPort(0, 0, oldW, oldH)

	local material = CreateMaterial(textureName, "UnlitGeneric", {
		["$basetexture"] = texture:GetName(),
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
	})
	customMaterial = material

	local materialData = {
		Texture = texture,
		Material = material,
		Width = width,
		Height = height,
		U = width / tWidth,
		V = height / tHeight,
	}

	return materialData
end

net.Receive("Star_Trek.LCARS.DisableEButton", function()
	local ply = LocalPlayer()

	ply.DisableEButton = true
end)

net.Receive("Star_Trek.LCARS.EnableEButton", function()
	local ply = LocalPlayer()

	ply.DisableEButton = nil
end)
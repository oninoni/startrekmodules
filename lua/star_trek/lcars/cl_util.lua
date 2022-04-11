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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--        LCARS Util | Client        --
---------------------------------------

-- Returns the position of the mouse in the 2d plane of the window.
--
-- @param Table window
-- @return Vector2D mousePos
function Star_Trek.LCARS:Get3D2DMousePos(window)
	local x, y = input.GetCursorPos()

	local xOffset, yOffset = hook.Run("Star_Trek.LCARS.GetMouseOffset", window)
	if xOffset and yOffset then
		x = x + xOffset
		y = y + yOffset
	end

	local rayDir = gui.ScreenToVector(x, y)

	local pos = util.IntersectRayWithPlane(self.EyePos, rayDir, window.WPosG, window.WAngG:Up())
	pos = WorldToLocal(pos or Vector(), Angle(), window.WPosG, window.WAngG)
	pos = Vector(pos[1] * window.WScale, pos[2] * -window.WScale, 0)

	local overriddenPos = hook.Run("Star_Trek.LCARS.Get3D2DMousePos", window, pos)
	if isvector(overriddenPos) then
		return overriddenPos
	end

	return pos
end

-- Determines the current Interface PosAngle of the entity.
-- Performs LocalToWorld Transform when possible and allows overriding with hook.
--
-- @param? Entity ent
-- @param Vector pos
-- @param Angle ang
-- @return Vector pos
-- @return Angle ang
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
	local maxCount = math.floor(listHeight / buttonHeight)

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

------------------------
--     Render Util    --
------------------------

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

------------------------
--  Vehicle E Button  --
------------------------

net.Receive("Star_Trek.LCARS.DisableEButton", function()
	local ply = LocalPlayer()

	ply.DisableEButton = true
end)
net.Receive("Star_Trek.LCARS.EnableEButton", function()
	local ply = LocalPlayer()

	ply.DisableEButton = nil
end)

------------------------
--     Networking     --
------------------------

function Star_Trek.LCARS:ReadNetTable()
	local size = net.ReadUInt(32)
	local compressedData = net.ReadData(size)

	return util.JSONToTable(util.Decompress(compressedData))
end
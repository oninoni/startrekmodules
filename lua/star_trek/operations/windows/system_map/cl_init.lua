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
--     LCARS System Map | Client     --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

function SELF:OnCreate(windowData)
	self.Padding = self.Padding or 1
	self.FrameType = self.FrameType or "frame"

	local success = SELF.Base.OnCreate(self, windowData)
	if not success then
		return false
	end

	self.Ships = {}
	for i = 0, 16 do
		local ship = {
			Pos = Vector(math.random(-18, 18), math.random(-18, 18), math.random(-5, 5)),
			Size = math.random(0.5, 2),
		}

		table.insert(self.Ships, ship)
	end

	self.Offset = 0

	-- TODO

	return self
end

function SELF:OnDraw(pos, animPos)
	-- TODO

	SELF.Base.OnDraw(self, pos, animPos)
end

function SELF:OnDraw3D(wPos, wAng, animPos)
	render.SetColorMaterial()

	local color = ColorAlpha(Star_Trek.LCARS.ColorLightBlue, animPos * 255)

	for _, ship in pairs(self.Ships) do
		local shipPos = LocalToWorld(ship.Pos, Angle(), wPos, wAng)
		render.DrawSphere(shipPos, ship.Size, 8, 8, color)
	end
end
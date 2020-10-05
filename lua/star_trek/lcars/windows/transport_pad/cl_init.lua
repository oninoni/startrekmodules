function WINDOW.OnCreate(self, windowData)
    self.Pads = windowData.Pads
    self.Title = windowData.Title

    return self
end

local function isHovered(x, y, r, pos)
    if math.Dist(x, y, pos.x, pos.y) < r then
        return true
    end

    return false
end

function WINDOW.OnPress(self, pos, animPos)
    local padRadius = self.WHeight / 8

    for i, pad in pairs(self.Pads) do
        local x = pad.X + 30
        local y = pad.Y + 30
        
        if isHovered(x, y, padRadius, pos) then
            return i
        end
    end
end

local function drawHexaeder(x, y, r, color)    
    surface.SetDrawColor(color)
	draw.NoTexture()

    local hex = {}

	table.insert( hex, {x= x, y= y})
	for i = 0, 6 do
		local a = math.rad( ( i / 6 ) * -360 )
		table.insert( hex, {x= x +(math.sin(a) * r), y= y +(math.cos(a) * r)})--, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( hex, {x= x +(math.sin(a) * r), y= y +(math.cos(a) * r)})--, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( hex )
end

local function drawPad(x, y, r, pos, round, selected, alpha)
    local lcars_white = Color(255, 255, 255, alpha)
    local lcars_black = Color(0, 0, 0, alpha)

    local isHovered = isHovered(x, y, r, pos)

    local color = Star_Trek.LCARS.ColorBlue
    if selected then
        color = Star_Trek.LCARS.ColorYellow
    end

    if round then
        local diameter = r * 2

        draw.RoundedBox(r, x -(r +2), y -(r +2), diameter +4, diameter +4, isHovered and lcars_white or lcars_black)
        draw.RoundedBox(r, x -r,      y -r,      diameter   , diameter   , color)
    else
        drawHexaeder(x, y, r + 2, isHovered and lcars_white or lcars_black)
        drawHexaeder(x, y, r    , color)
    end
end

function WINDOW.OnDraw(self, pos, animPos)
    local width = self.WWidth
    local wd2 = width / 2
    local height = self.WHeight
    local hd2 = height / 2
    --draw.RoundedBox(0, -wd2, -hd2, width, height, Color(127, 127, 127))

    local padRadius = height / 8

    for i, pad in pairs(self.Pads) do
        local x = pad.X + 30
        local y = pad.Y + 30

        if pad.Type == "Round" then
            drawPad(x, y, padRadius, pos, true, pad.Selected, animPos * 255)
        elseif pad.Type == "Hex" then
            drawPad(x, y, padRadius, pos, false, pad.Selected, animPos * 255)
        end

        draw.SimpleText(i, "LCARSSmall", x, y, Color(0, 0, 0, animPos * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    Star_Trek.LCARS:DrawFrame(width, wd2, hd2, self.Title, 255 * animPos)
end
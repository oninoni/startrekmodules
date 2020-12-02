function WINDOW.OnCreate(self, windowData)
    self.Pads = windowData.Pads
    self.Title = windowData.Title

    self.WD2 = self.WWidth / 2
    self.HD2 = self.WHeight / 2

    self.PadRadius = self.WHeight / 8

    self.HexValues = {}
    for i = 1, 6 do
        local a = math.rad( ( i / 6 ) * -360 )

        self.HexValues[i] = {
            x = math.sin(a),
            y = math.cos(a),
        }
    end
    table.insert(self.HexValues, self.HexValues[1])

    self.FrameMaterial = Star_Trek.LCARS:CreateFrame(self.Id, self.WWidth, self.WHeight, self.Title)

    return self
end

local function isHovered(x, y, r, pos)
    if math.Distance(x, y, pos.x, pos.y) < r then
        return true
    end

    return false
end

function WINDOW.OnPress(self, pos, animPos)
    for i, pad in pairs(self.Pads) do
        if isHovered(pad.X, pad.Y, self.PadRadius, pos) then
            return i
        end
    end
end

local function drawHexaeder(self, x, y, r, color)
    surface.SetDrawColor(color)
    draw.NoTexture()

    local hex = {{x = x, y = y}}
    for _, vert in pairs(self.HexValues) do
        table.insert( hex, {
            x = x + (vert.x * r),
            y = y + (vert.y * r),
        })
    end

    surface.DrawPoly(hex)
end

local function drawPad(self, x, y, r, pos, round, selected, alpha)
    local lcars_white = Color(255, 255, 255, alpha)
    local lcars_black = Color(0, 0, 0, alpha)

    local isHov = isHovered(x, y, r, pos)

    local color = Star_Trek.LCARS.ColorBlue
    if selected then
        color = Star_Trek.LCARS.ColorYellow
    end

    if round then
        local diameter = r * 2

        draw.RoundedBox(r, x -(r + 2), y -(r + 2), diameter + 4, diameter + 4, isHov and lcars_white or lcars_black)
        draw.RoundedBox(r, x -r,       y -r,       diameter    , diameter    , color)
    else
        drawHexaeder(self, x, y, r + 2, isHov and lcars_white or lcars_black)
        drawHexaeder(self, x, y, r    , color)
    end
end

function WINDOW.OnDraw(self, pos, animPos)
    for i, pad in pairs(self.Pads) do
        if pad.Type == "Round" then
            drawPad(self, pad.X, pad.Y, self.PadRadius, pos, true, pad.Selected, animPos * 255)
        elseif pad.Type == "Hex" then
            drawPad(self, pad.X, pad.Y, self.PadRadius, pos, false, pad.Selected, animPos * 255)
        end

        draw.SimpleText(i, "LCARSSmall", pad.X, pad.Y, Color(0, 0, 0, animPos * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    surface.SetDrawColor(255, 255, 255, alpha)

    surface.SetMaterial(self.FrameMaterial)
    surface.DrawTexturedRect(-self.WD2, -self.HD2, self.WWidth, self.WHeight)

    surface.SetAlphaMultiplier(1)
end
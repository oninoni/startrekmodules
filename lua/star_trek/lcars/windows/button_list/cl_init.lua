function WINDOW.OnCreate(self, windowData)
    self.Buttons = windowData.Buttons

    return self
end

-- Calculate the scroll of the list.
local function getOffset(height, n, y)
    local max = math.floor(height / 35)

    if n > max then
        return -y * ((n - max + 2) / max)
    end
    
    return 0
end

-- Calculate the y position of an element.
local function getButtonYPos(height, i, n, offset, animPos)
    local max = math.floor(height / 35) + 1

    local y = (i - (n / 2)) * 35 + offset

    if offset == 0 then
        y = math.min(
            math.max(
                -height / 2 - 35,
                y),
            height / 2 + 70)
    else
        y = math.min(
            math.max(
                height / 2 - (n - i) * 35,
                -height / 2 - 35,
                y),
            -height / 2 + i * 35,
            height / 2 + 70)
    end

    return math.floor((y - 17.5) * animPos)
end

function WINDOW.OnPress(self, pos, animPos)
    local buttons = self.Buttons
    local n = table.maxn(buttons)

    local height = self.WHeight

    local offset = getOffset(height, n, pos.y)
    for i, button in pairs(buttons) do
        if button.Disabled then continue end
        
        local y = getButtonYPos(height, i, n, offset, animPos)
        if pos.y >= y - 16 and pos.y <= y + 16 then
            return i
        end
    end
end

-- Drawing a normal LCARS panel button. (2D Rendering Context)
--
-- @param Number x
-- @param Number y
-- @param Number width (min 300)
-- @param Text text
-- @param Color color
-- @param? Boolean selected
-- @param? String s
-- @param? String l
-- @param? Number alpha
function drawButton(x, y, width, text, color, selected, s, l, alpha)
    local lcars_white = Color(255, 255, 255, alpha)
    local lcars_black = Color(0, 0, 0, alpha)
    color = ColorAlpha(color, alpha)

    local widthDiff = math.max(0, width - 300)
    local widthOffset = widthDiff / 2

    draw.RoundedBox(16, -121 + x - widthOffset, y - 1, 242 + widthDiff, 32, selected and lcars_white or lcars_black)
    draw.RoundedBox(15, -120 + x - widthOffset, y, 240 + widthDiff, 30, color)
    draw.RoundedBox(0, -100 + x - widthOffset, y, 10, 30, lcars_black)
    draw.RoundedBox(0, 55 + x + widthOffset, y, 15, 30, lcars_black)
    draw.RoundedBox(0, 0 + x + widthOffset, y, 45, 30, lcars_black)

    if #s == 1 then
        draw.DrawText(s, "LCARSBig", 21 + x + widthOffset, y - 4, color, TEXT_ALIGN_LEFT)
    else
        draw.DrawText(s, "LCARSBig", 3 + x + widthOffset, y - 4, color, TEXT_ALIGN_LEFT)
    end

    draw.DrawText(text, "LCARSText", -88 + x - widthOffset, y + 14, lcars_black, TEXT_ALIGN_LEFT)
    draw.DrawText(l, "LCARSSmall", 71 + x + widthOffset, y + 18, lcars_black, TEXT_ALIGN_LEFT)
end

local colors = Star_Trek.LCARS.Colors
local nColors = #(colors)
local color_grey = Star_Trek.LCARS.ColorGrey

function WINDOW.OnDraw(self, pos, animPos)
    local buttons = self.Buttons
    local n = table.maxn(buttons)

    local width = self.WWidth
    local height = self.WHeight
    --draw.RoundedBox(0, -width / 2, -height / 2, width, height, Color(255, 255, 255))

    local offset = getOffset(height, n, pos.y)
    for i, button in pairs(buttons) do
        local color = button.Color or colors[(i - 1) % nColors + 1]
        if button.Disabled then
            color = color_grey
        end

        local y = getButtonYPos(height, i, n, offset, animPos)

        local alpha = 255
        if y < -height / 2 or y > height / 2 then
            alpha = math.max(0, 40 - (math.abs(y) - (height / 2))) / 40 * 255
        end

        local text = button.Name or "[ERROR]"

        local selected = false
        if animPos == 1 and pos.y >= y - 16 and pos.y <= y + 16 then
            selected = true
        end

        drawButton(0, y - 15, width, text, color, selected, button.RandomS, button.RandomL, animPos * alpha)
    end
end
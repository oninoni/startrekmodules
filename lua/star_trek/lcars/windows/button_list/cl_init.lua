function WINDOW.OnCreate(self, windowData)
    self.Title = windowData.Title
    self.Buttons = windowData.Buttons

    return self
end

-- Calculate the scroll of the list.
local function getOffset(height, n, y)
    height = height - 70
    y = y - 35

    local max = math.floor(height / 35)

    if n > max then
        return -y * ((n - max + 2) / max)
    end
    
    return 0
end

-- Calculate the y position of an element.
local function getButtonYPos(height, i, n, offset)
    height = height - 70

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

    return math.floor(y - 17.5) + 30
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
-- @param? String s
-- @param? String l
-- @param? Number alpha
local function drawButton(x, y, width, text, color, s, l, alpha, pos)
    local lcars_white = Color(255, 255, 255, alpha)
    local lcars_black = Color(0, 0, 0, alpha)
    color = ColorAlpha(color, alpha)

    s = s or ""
    l = l or ""

    local widthDiff = math.max(0, width - 300)
    local widthOffset = widthDiff / 2

    local selected = false
    if pos.x >= (x -123 -widthOffset) and pos.x <= (width /2) and pos.y >= (y -1) and pos.y <= (y +32) then
        selected = true
    end

    draw.RoundedBox(16, -123 + x - widthOffset, y - 1, 240 + widthDiff, 32, selected and lcars_white or lcars_black)
    draw.RoundedBox(15, -122 + x - widthOffset, y, 238 + widthDiff, 30, color)
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
    local wd2 = width / 2
    local height = self.WHeight
    local hd2 = height / 2
    --draw.RoundedBox(0, -wd2, -hd2, width, height, Color(127, 127, 127))

    local offset = getOffset(height, n, pos.y)
    for i, button in pairs(buttons) do
        local color = button.Color or colors[(i - 1) % nColors + 1]
        if button.Disabled then
            color = color_grey
        elseif button.Selected then
            color = Star_Trek.LCARS.ColorYellow
        end

        local y = getButtonYPos(height, i, n, offset)

        local alpha = 255
        if y < -68 or y > 125 then
            if y < -68 then
                alpha =-y -(hd2 -80)
            else
                alpha = y -(hd2 -16)
            end
            
            alpha = math.min(math.max(0, 255 - alpha * 10), 255)
        end
        alpha = alpha * animPos

        local text = button.Name or "[ERROR]"

        drawButton(26, y - 15, width, text, color, button.RandomS, button.RandomL, alpha, pos)
    end

    Star_Trek.LCARS:DrawFrame(x, y, width, wd2, hd2, self.Title, 255 * animPos)
end
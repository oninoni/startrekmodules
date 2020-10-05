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
--    Copyright © 2020 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--        LCARS Util | Client        --
---------------------------------------

-- Calculate the ammount of scroll/offset of a button list.
--
-- @param Number listHeight
-- @param Number buttonCount
-- @param Number mouseYPos
-- @return Number offset
function Star_Trek.LCARS:GetButtonOffset(listHeight, buttonCount, mouseYPos)
    local max = math.floor(listHeight / 35)

    if buttonCount > max then
        return -mouseYPos * ((buttonCount - max + 2) / max)
    end
    
    return 0
end

-- @param Number listHeight
-- @param Number i
-- @param Number buttonCount
-- @param Number offset
-- @return Number yPos
function Star_Trek.LCARS:GetButtonYPos(listHeight, i, buttonCount, offset)
    local max = math.floor(listHeight / 35) + 1

    local y = (i - (buttonCount / 2)) * 35 + offset

    if offset == 0 then
        y = math.min(
            math.max(
                -listHeight / 2 - 35,
                y),
            listHeight / 2 + 70)
    else
        y = math.min(
            math.max(
                listHeight / 2 - (buttonCount - i) * 35,
                -listHeight / 2 - 35,
                y),
            -listHeight / 2 + i * 35,
            listHeight / 2 + 70)
    end

    return math.floor(y - 17.5) + 30
end

-- Draw a spacer of the LCARS interface
function Star_Trek.LCARS:DrawFrameSpacer(y, width, wd2, lcars_black, lcars_top, lcars_bottom)
    -- Top Bar
    draw.RoundedBox(25, -wd2    , y -38,       50,      50, lcars_black)
    draw.RoundedBox( 0, -wd2    , y -38,       50,      25, lcars_black)
    draw.RoundedBox( 0, -wd2 +25, y -13,       25,      25, lcars_black)

    draw.RoundedBox( 0, -wd2 +25, y  +1, width-25,      11, lcars_black)
    
    draw.RoundedBox(24, -wd2  +1, y -37,       48,      48, lcars_top)
    draw.RoundedBox( 0, -wd2  +1, y -37,       48,      25, lcars_top)
    draw.RoundedBox( 0, -wd2 +25, y -13,       24,      24, lcars_top)

    draw.RoundedBox( 0, -wd2 +25, y  +2, width-25,       9, lcars_top)

    -- Bottom Bar
    draw.RoundedBox(25, -wd2    , y +14,       50,      50, lcars_black)
    draw.RoundedBox( 0, -wd2    , y +40,       50,      26, lcars_black)
    draw.RoundedBox( 0, -wd2 +25, y +14,       25,      25, lcars_black)
    
    draw.RoundedBox( 0, -wd2 +25, y +14, width-25,      11, lcars_black)

    draw.RoundedBox(24, -wd2  +1, y +15,       48,      48, lcars_bottom)
    draw.RoundedBox( 0, -wd2  +1, y +40,       48,      25, lcars_bottom)
    draw.RoundedBox( 0, -wd2 +25, y +15,       24,      24, lcars_bottom)
    
    draw.RoundedBox( 0, -wd2 +25, y +15, width-25,       9, lcars_bottom)
    
end

-- Draw the fram of an LCARS interface
function Star_Trek.LCARS:DrawFrame(width, wd2, hd2, title, alpha)
    local lcars_black = Color(0, 0, 0, alpha)
    local lcars_top = ColorAlpha(Star_Trek.LCARS.ColorOrange, alpha)
    local lcars_bottom = ColorAlpha(Star_Trek.LCARS.ColorLightRed, alpha)
    
    self:DrawFrameSpacer(-hd2 +35, width, wd2, lcars_black, lcars_top, lcars_bottom)

    -- Middle Red Bars
    draw.RoundedBox(0, -wd2   , -hd2 + 80, 50, hd2 -60, lcars_black)
    draw.RoundedBox(0, -wd2 +1, -hd2 + 80, 48, hd2 -60, lcars_bottom)
    
    -- Bottom Orange Bars
    draw.RoundedBox(0, -wd2   ,         0, 50, hd2    , lcars_black)
    draw.RoundedBox(0, -wd2 +1,         0, 48, hd2    , lcars_top)
    
    -- Small Black Bars
    draw.RoundedBox(0, -wd2, -hd2 +100, 50, 2, lcars_black)

    draw.RoundedBox(0, -wd2,   0, 50, 2, lcars_black)
    draw.RoundedBox(0, -wd2,  20, 50, 2, lcars_black)
    
    -- Title
    draw.DrawText(title, "LCARSBig", wd2 -8, -hd2 -2, color_white, TEXT_ALIGN_RIGHT)
end

function Star_Trek.LCARS:DrawButtonGraphic(x, y, width, height, color, alpha, pos)
    local lcars_white = Color(255, 255, 255, alpha)
    local lcars_black = Color(0, 0, 0, alpha)
    color = ColorAlpha(color, alpha)
    
    local selected = false
    if isvector(pos) and pos.x >= (x -1) and pos.x <= (x +width) and pos.y >= (y -1) and pos.y <= (y +height) then
        selected = true
    end

    draw.RoundedBox(16, x -1, y -1, width, height, selected and lcars_white or lcars_black)
    draw.RoundedBox(15, x, y, width -2, height -2, color)
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
-- @param? Vector pos
function Star_Trek.LCARS:DrawButton(x, y, width, text, color, s, l, alpha, pos)
    local lcars_white = Color(255, 255, 255, alpha)
    local lcars_black = Color(0, 0, 0, alpha)
    color = ColorAlpha(color, alpha)

    local widthDiff = math.max(0, width - 300)
    local widthOffset = widthDiff / 2

    self:DrawButtonGraphic(x -123 -widthOffset, y, 240 + widthDiff, 32, color, alpha, pos)
    draw.RoundedBox(0, -100 + x - widthOffset, y, 10, 30, lcars_black)
    draw.RoundedBox(0, 55 + x + widthOffset, y, 15, 30, lcars_black)
    draw.RoundedBox(0, 0 + x + widthOffset, y, 45, 30, lcars_black)

    s = s or ""
    l = l or ""

    if #s == 1 then
        draw.DrawText(s, "LCARSBig", 21 + x + widthOffset, y - 4, color, TEXT_ALIGN_LEFT)
    else
        draw.DrawText(s, "LCARSBig", 3 + x + widthOffset, y - 4, color, TEXT_ALIGN_LEFT)
    end

    draw.DrawText(text, "LCARSText", -88 + x - widthOffset, y + 14, lcars_black, TEXT_ALIGN_LEFT)
    draw.DrawText(l, "LCARSSmall", 71 + x + widthOffset, y + 18, lcars_black, TEXT_ALIGN_LEFT)
end
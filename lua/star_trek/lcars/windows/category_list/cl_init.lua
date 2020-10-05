function WINDOW.OnCreate(self, windowData)
    self.Title = windowData.Title
    self.Selected = windowData.Selected
    self.Categories = windowData.Categories

    return self
end

-- Calculate the scroll of the list.
local function getOffset(height, n, y)
    height = height - 240
    y = y - 115

    return Star_Trek.LCARS:GetButtonOffset(height, n, y)
end

-- Calculate the y position of an element.
local function getButtonYPos(height, i, n, offset)
    height = height - 240

    return Star_Trek.LCARS:GetButtonYPos(height, i, n, offset) + 85
end

local function isSmallButtPressed(x, y, width, height, pos)
    return pos.x > x -1 and pos.x < x +width and pos.y > y -1 and pos.y < y +height
end

function WINDOW.OnPress(self, pos, animPos)
    local selected = self.Selected
    
    local width = self.WWidth
    local wd2 = width / 2
    local height = self.WHeight
    local hd2 = height / 2
    
    local smallButtWidth = (width -58)/4

    if pos.y <= -hd2 +205 then
        -- Selection
        
        for y=1,4,1 do
            for x=1,4,1 do
                local id = (y-1)*4 + x
                local categoryData = self.Categories[id]
                if istable(categoryData) then
                    if isSmallButtPressed(-wd2 +53 +(x-1)*smallButtWidth, -hd2 +30 +y*35, smallButtWidth -3, 32, pos) then
                        return id
                    end
                end
            end
        end
    else
        -- Button List
        if selected and istable(self.Categories[selected]) then
            local buttons = self.Categories[selected].Buttons
            local n = table.maxn(buttons)

            local offset = getOffset(height, n, pos.y)
            for i, button in pairs(buttons) do
                if button.Disabled then continue end
                
                local y = getButtonYPos(height, i, n, offset)
                if pos.y >= y - 16 and pos.y <= y + 16 then
                    return #(self.Categories) + i
                end
            end
        end
    end
end

local color_grey = Star_Trek.LCARS.ColorGrey
local color_yellow = Star_Trek.LCARS.ColorYellow
local color_blues = {
    Star_Trek.LCARS.ColorLightBlue,
    Star_Trek.LCARS.ColorBlue,
}

function WINDOW.OnDraw(self, pos, animPos)
    local selected = self.Selected

    local width = self.WWidth
    local wd2 = width / 2
    local height = self.WHeight
    local hd2 = height / 2

    local smallButtWidth = (width -58)/4
    
    local alpha = 255 * animPos
    local lcars_black = Color(0, 0, 0, alpha)

    for y=1,4,1 do
        for x=1,4,1 do
            local id = (y-1)*4 + x
            local categoryData = self.Categories[id]
            if istable(categoryData) then
                local color = color_blues[(x+y)%2 +1] 
                if selected == id then
                    color = color_yellow
                end
                
                if categoryData.Disabled then
                    color = color_grey
                end

                Star_Trek.LCARS:DrawButtonGraphic(-wd2 +53 +(x-1)*smallButtWidth, -hd2 +30 +y*35, smallButtWidth -3, 32, color, alpha, pos)

                draw.DrawText(categoryData.Name, "LCARSText", -wd2 +62 +(x-1)*smallButtWidth, -hd2 +43 +y*35, lcars_black, TEXT_ALIGN_LEFT)
            end
        end
    end

    if selected and istable(self.Categories[selected]) then
        local buttons = self.Categories[selected].Buttons
        local n = table.maxn(buttons)

        local offset = getOffset(height, n, pos.y)
        for i, button in pairs(buttons) do
            local color = button.Color
            if button.Disabled then
                color = color_grey
            elseif button.Selected then
                color = color_yellow
            end

            local y = getButtonYPos(height, i, n, offset)

            local alpha = 255
            if y < -5 or y > 240 then
                if y < -5 then
                    alpha =-y -(hd2 -245)
                else
                    alpha = y -(hd2 -20)
                end
                
                alpha = math.min(math.max(0, 255 - alpha * 10), 255)
            end
            alpha = alpha * animPos

            local title = button.Name or "[ERROR]"

            Star_Trek.LCARS:DrawButton(26, y - 15, width, title, color, button.RandomS, button.RandomL, alpha, pos)
        end
    end

    -- Custom Drawing the Double Frame
    local lcars_black = Color(0, 0, 0, alpha)
    local lcars_top = ColorAlpha(Star_Trek.LCARS.ColorOrange, alpha)
    local lcars_middle = ColorAlpha(Star_Trek.LCARS.ColorLightRed, alpha)
    local lcars_bottom = ColorAlpha(Star_Trek.LCARS.ColorYellow, alpha)
    
    -- Title
    draw.DrawText(self.Title, "LCARSBig", wd2 -8, -hd2 -2, color_white, TEXT_ALIGN_RIGHT)

    Star_Trek.LCARS:DrawFrameSpacer(-hd2  +35, width, wd2, lcars_black, lcars_top, lcars_middle)
    Star_Trek.LCARS:DrawFrameSpacer(-hd2 +205, width, wd2, lcars_black, lcars_middle, lcars_bottom)
    
    -- Middle Bars
    draw.RoundedBox(0, -wd2   , -hd2 +80, 50, 100, lcars_black)
    draw.RoundedBox(0, -wd2 +1, -hd2 +80, 48, 100, lcars_middle)
    
    -- Bottom Red Bars 
    draw.RoundedBox(0, -wd2   , -hd2 +250, 50, hd2 -60, lcars_black)
    draw.RoundedBox(0, -wd2 +1, -hd2 +250, 48, hd2 -60, lcars_bottom)
    
    -- Very Bottom Orange Bars
    draw.RoundedBox(0, -wd2   , 100, 50, hd2 -100, lcars_black)
    draw.RoundedBox(0, -wd2 +1, 100, 48, hd2 -100, lcars_top)
    
    -- Small Black Bars
    draw.RoundedBox(0, -wd2, -hd2 +100, 50, 2, lcars_black)
    
    draw.RoundedBox(0, -wd2, 100, 50, 2, lcars_black)
    draw.RoundedBox(0, -wd2, 120, 50, 2, lcars_black)
end
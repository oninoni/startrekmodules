function WINDOW.OnCreate(self, windowData)
    self.Title = windowData.Title
    self.Buttons = windowData.Buttons

    return self
end

-- Calculate the scroll of the list.
local function getOffset(height, n, y)
    height = height - 70
    y = y - 35

    return Star_Trek.LCARS:GetButtonOffset(height, n, y)
end

-- Calculate the y position of an element.
local function getButtonYPos(height, i, n, offset)
    height = height - 70

    return Star_Trek.LCARS:GetButtonYPos(height, i, n, offset)
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

local color_grey = Star_Trek.LCARS.ColorGrey
local color_yellow = Star_Trek.LCARS.ColorYellow

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
        local color = button.Color
        if button.Disabled then
            color = color_grey
        elseif button.Selected then
            color = color_yellow
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

        local title = button.Name or "[ERROR]"

        Star_Trek.LCARS:DrawButton(26, y - 15, width, title, color, button.RandomS, button.RandomL, alpha, pos)
    end

    Star_Trek.LCARS:DrawFrame(width, wd2, hd2, self.Title, 255 * animPos)
end
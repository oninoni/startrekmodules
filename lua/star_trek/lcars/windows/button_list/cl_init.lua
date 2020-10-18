function WINDOW.OnCreate(self, windowData)
    self.Title = windowData.Title
    self.Buttons = windowData.Buttons

    self.WD2 = self.WWidth / 2
    self.HD2 = self.WHeight / 2

    self.MaxN = table.maxn(buttons)

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
    local offset = getOffset(self.WHeight, self.MaxN, pos.y)
    for i, button in pairs(self.Buttons) do
        if button.Disabled then continue end

        local y = getButtonYPos(self.WHeight, i, n, offset, animPos)
        if pos.y >= y - 16 and pos.y <= y + 16 then
            return i
        end
    end
end

local color_grey = Star_Trek.LCARS.ColorGrey
local color_yellow = Star_Trek.LCARS.ColorYellow

function WINDOW.OnDraw(self, pos, animPos)
    local offset = getOffset(self.WHeight, self.MaxN, pos.y)
    for i, button in pairs(self.Buttons) do
        local color = button.Color
        if button.Disabled then
            color = color_grey
        elseif button.Selected then
            color = color_yellow
        end

        local y = getButtonYPos(self.WHeight, i, self.MaxN, offset)

        local alpha = 255
        if y < -68 or y > 125 then
            if y < -68 then
                alpha = -y -(self.HD2 -80)
            else
                alpha = y -(self.HD2 -16)
            end

            alpha = math.min(math.max(0, 255 - alpha * 10), 255)
        end
        alpha = alpha * animPos

        local title = button.Name or "[ERROR]"
        Star_Trek.LCARS:DrawButton(26, y - 15, self.WWidth, title, color, button.RandomS, button.RandomL, alpha, pos)
    end

    Star_Trek.LCARS:DrawFrame(self.WWidth, self.WD2, self.HD2, self.Title, 255 * animPos)
end
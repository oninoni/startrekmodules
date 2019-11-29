

local WINDOW = {}

-- Calculate the scroll of the list.
function WINDOW:GetOffset(window, n, y)
    if n > math.floor(window.Height / 35) then
        return ((y - window.Pos.y) + 17.5) / ((n - 2) * 35) * -((n + 2) * 35)
    end

    return 0
end

-- Calculate the y position of an element.
function WINDOW:GetButtonYPos(window, i, n, offset, menuPos)
    local y = (i - (n / 2)) * 35 + offset + window.Pos.y
    y = math.min(
            math.max(
                -(window.Height / 2)
                , y)
            , window.Height / 2)

    return math.floor((y - 17.5) * menuPos)
end

-- Checks if a press action should be returned to the server with an id.
-- 
-- @param Panel panel
-- @param Window window
-- @param Vector pos (2D Vector)
function WINDOW:IsPressed(panel, window, pos)
    local n = #(window.Buttons)

    local offset = self:GetOffset(window, n, pos.y)

    for i, button in pairs(window.Buttons) do
        if button.Disabled then continue end
        
        local y = self:GetButtonYPos(window, i, n, offset, panel.MenuPos)

        if y < -130 or y > 130 then continue end

        if pos.y >= y - 15 and pos.y <= y + 15 then
            panel.MenuClosing = true
            return i
        end
    end
end

-- Draws the Window
-- 
-- @param Panel panel
-- @param Window window
-- @param Vector pos (2D Vector)
function WINDOW:DrawWindow(panel, window, pos)
    local n = #(window.Buttons)

    local offset = self:GetOffset(window, n, pos.y)

    for i, button in pairs(window.Buttons) do
        local y = self:GetButtonYPos(window, i, n, offset, panel.MenuPos)

        local nColors = #(LCARS.Colors)
        local color = button.Color or LCARS.Colors[(i - 1) % nColors + 1]
        if button.Disabled then
            color = LCARS.ColorGrey
        end

        local text = button.Name or "[ERROR]"

        local selected = false
        if panel.MenuPos == 1 and pos.y >= y - 15 and pos.y <= y + 15 then
            selected = true
        end

        LCARS:DrawButton(window.Pos.x, y - 15 , text, color, selected, button.RandomS, button.RandomL, panel.MenuPos * 255)
    end
end

LCARS.Windows["button_list"] = WINDOW
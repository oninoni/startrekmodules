

local WINDOW = {}

-- Calculate the scroll of the list.
function WINDOW:GetOffset(window, n, y)
    local max = math.floor(window.Height / 35)

    if n > max then
        return -y * ((n - max + 2) / max)
    end
    
    return 0
end

-- Calculate the y position of an element.
function WINDOW:GetButtonYPos(window, i, n, offset, menuPos)
    local max = math.floor(window.Height / 35) + 1

    local y = (i - (n / 2)) * 35 + offset

    if offset == 0 then
        y = math.min(
                math.max(
                    -window.Height / 2 - 35,
                    y),
                window.Height / 2 + 70)
    else
        y = math.min(
                math.max(
                    window.Height / 2 - (n - i) * 35,
                    -window.Height / 2 - 35,
                    y),
                -window.Height / 2 + i * 35,
                window.Height / 2 + 70)
    end

    return math.floor((y - 17.5) * menuPos)
end

-- Checks if a press action should be returned to the server with an id.
-- 
-- @param Panel panel
-- @param Window window
-- @param Vector pos (2D Vector)
function WINDOW:IsPressed(panel, window, pos)
    local n = table.maxn(window.Buttons)

    local offset = self:GetOffset(window, n, pos.y)

    for i, button in pairs(window.Buttons) do
        if button.Disabled then continue end
        
        local y = self:GetButtonYPos(window, i, n, offset, panel.MenuPos)

        if y < -window.Height / 2 or y > window.Height / 2 then continue end

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
    local n = table.maxn(window.Buttons)

    --draw.RoundedBox(0, -window.Width / 2, -window.Height / 2, window.Width, window.Height, Color(255, 255, 255, 255))

    local offset = self:GetOffset(window, n, pos.y)

    for i, button in pairs(window.Buttons) do
        local y = self:GetButtonYPos(window, i, n, offset, panel.MenuPos)

        local nColors = #(LCARS.Colors)
        local color = button.Color or LCARS.Colors[(i - 1) % nColors + 1]
        if button.Disabled then
            color = LCARS.ColorGrey
        end

        local alpha = 255
        if y < -window.Height / 2 or y > window.Height / 2 then
            alpha = math.max(0, 40 - (math.abs(y) - (window.Height / 2))) / 40 * 255
        end

        local text = button.Name or "[ERROR]"

        local selected = false
        if panel.MenuPos == 1 and pos.y >= y - 15 and pos.y <= y + 15 then
            selected = true
        end

        LCARS:DrawButton(0, y - 15, window.Width, text, color, selected, button.RandomS, button.RandomL, panel.MenuPos * alpha)
    end
end

LCARS.Windows["button_list"] = WINDOW
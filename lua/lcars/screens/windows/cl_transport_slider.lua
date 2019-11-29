

local WINDOW = {}

-- Checks if a press action should be returned to the server with an id.
-- 
-- @param Panel panel
-- @param Window window
-- @param Vector pos (2D Vector)
function WINDOW:IsPressed(panel, window, pos)
    if window.TargetState ~= window.State then return end

    if window.TargetState == nil or window.TargetState == -window.Height / 2 then
        window.TargetState = window.Height / 2
        window.Lerp = 0

        timer.Simple(3, function()
            window.TargetState = -window.Height / 2
            window.Lerp = 0
        end)

        return 1
    end
end

-- Draws the Window
-- 
-- @param Panel panel
-- @param Window window
-- @param Vector pos (2D Vector)
function WINDOW:DrawWindow(panel, window, pos)
    local colorBlue = ColorAlpha(LCARS.ColorDarkBlue, panel.MenuPos * 255)
    local colorYellow = ColorAlpha(LCARS.ColorYellow, panel.MenuPos * 255)

    local hWidth = window.Width / 32
    local hWOffset = -hWidth / 2
    local hHeightSteps = window.Height / 16
    local hHeight = hHeightSteps - hWidth / 2
    local hHOffset = -hHeight / 2

    local yHeight = (hHeight) * panel.MenuPos

    for i=1,16,1 do
        local yOffset = (window.Pos.y + (i - 8.5) * hHeightSteps + hHOffset) * panel.MenuPos
        
        draw.RoundedBox(0, window.Pos.x - window.Width * (1/6) + hWOffset, yOffset, hWidth, yHeight, colorBlue)
        draw.RoundedBox(0, window.Pos.x + window.Width * (1/6) + hWOffset, yOffset, hWidth, yHeight, colorBlue)
    end

    local wWidthSteps = window.Width / 3
    local wWidth = wWidthSteps - hWidth * 2
    local wWOffset = -wWidth / 2
    local wHeight = window.Height / 12
    local wHOffset = -wHeight / 2

    if window.TargetState ~= nil and window.TargetState ~= window.State then
        window.State = Lerp(window.Lerp, -window.TargetState, window.TargetState)
        window.Lerp = window.Lerp + FrameTime() / 1.5
    end

    local y = -math.min(window.Height * 0.45, math.max(window.Height * -0.45, window.State or -window.Height / 2))

    local yOffset = (window.Pos.y + wHOffset + y) * panel.MenuPos
    local yHeight = (wHeight) * panel.MenuPos

    for i=1,3,1 do
        draw.RoundedBox(0, window.Pos.x + (i - 2) * wWidthSteps + wWOffset , yOffset, wWidth, yHeight, colorYellow)
    end
end

LCARS.Windows["transport_slider"] = WINDOW
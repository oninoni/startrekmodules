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
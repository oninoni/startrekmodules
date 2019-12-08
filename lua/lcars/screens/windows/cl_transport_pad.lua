

local WINDOW = {}

function WINDOW:IsPadPressed(x, y, pos, radius)
    if math.Dist(x, y, pos.x, pos.y) < radius then
        return true
    end

    return false
end

function WINDOW:DrawHexaeder(x, y, radius, color)
    surface.SetDrawColor(color or LCARS.ColorBlue)
	draw.NoTexture()

    local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, 6 do
		local a = math.rad( ( i / 6 ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function WINDOW:DrawHexPad(x, y, radius, pos, selected)
    local pressed = self:IsPadPressed(x, y, pos, radius)

    local color = Color(0, 0, 0)
    if pressed then
        color = Color(255, 255, 255)
    end

    self:DrawHexaeder(x, y, radius + 2, color)

    local color = LCARS.ColorBlue
    if selected then
        color = LCARS.ColorYellow
    end

    self:DrawHexaeder(x, y, radius, color)
end

function WINDOW:DrawRoundPad(x, y, radius, pos, selected)
    local pressed = self:IsPadPressed(x, y, pos, radius)
    local diameter = radius * 2

    local color = Color(0, 0, 0)
    if pressed then
        color = Color(255, 255, 255)
    end

    draw.RoundedBox(radius, -(radius + 2), -(radius + 2), diameter + 4, diameter + 4, color)

    local color = LCARS.ColorBlue
    if selected then
        color = LCARS.ColorYellow
    end

    draw.RoundedBox(radius, -radius, -radius, diameter, diameter, color)
end

-- Checks if a press action should be returned to the server with an id.
-- 
-- @param Panel panel
-- @param Window window
-- @param Vector pos (2D Vector)
function WINDOW:IsPressed(panel, window, pos)
    for i, button in pairs(window.Buttons) do
        if self:IsPadPressed(button.X, button.Y, pos, button.Radius) then
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
    local padDiameter = window.Height / 4
    local padRadius = padDiameter / 2

    local outerPadOffset = padDiameter + padRadius / 2
    local outerPadX = 0.5 * outerPadOffset
    local outerPadY = 0.866 * outerPadOffset
    
    for i, button in pairs(window.Buttons) do
        if button.Type == "Round" then
            WINDOW:DrawRoundPad(button.X, button.Y, button.Radius, pos, button.Selected)
        elseif button.Type == "Hex" then
            WINDOW:DrawHexPad(button.X, button.Y, button.Radius, pos, button.Selected)
        end
    end
end

LCARS.Windows["transport_pad"] = WINDOW
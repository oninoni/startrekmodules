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
-- @param Number listOffset
-- @param Number listHeight
-- @param Number buttonCount
-- @param Number mouseYPos
-- @return Number offset
function Star_Trek.LCARS:GetButtonOffset(listOffset, listHeight, buttonCount, mouseYPos)
    local maxCount = math.floor(listHeight / 35) - 1

    local offset = listOffset
    if buttonCount > maxCount then
        offset = listOffset - (mouseYPos - listOffset) * ((buttonCount - maxCount) / maxCount) + 30

        offset = math.min(offset, listOffset)
        offset = math.max(offset, listOffset - (buttonCount + 1) * 35 + (maxCount + 2) * 35)
    end

    return offset
end

-- Generates the offset of a single button.
-- @param Number listHeight
-- @param Number i
-- @param Number buttonCount
-- @param Number offset
-- @return Number yPos
function Star_Trek.LCARS:GetButtonYPos(listHeight, i, buttonCount, offset)
    local y = (i - 1) * 35 + offset

    return y
end

local LCARS_CORNER_RADIUS = 25
local LCARS_INNER_RADIUS = 15
local LCARS_FRAME_OFFSET = 4
local LCARS_BORDER_WIDTH = 2
local LCARS_STRIP_HEIGHT = 20

-- TODO: Redo
function Star_Trek.LCARS:DrawButtonGraphic(x, y, width, height, color, alpha, pos)
    local lcars_white = Color(255, 255, 255, alpha)
    local lcars_black = Color(0, 0, 0, alpha)

    color = ColorAlpha(color, alpha)

    local selected = false
    if isvector(pos) and pos.x >= (x -1) and pos.x <= (x + width) and pos.y >= (y -1) and pos.y <= (y + height) then
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

-- TODO: Redo
function Star_Trek.LCARS:DrawButton(x, y, width, text, color, s, l, alpha, pos)
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

function Star_Trek.LCARS:DrawCircle(x, y, radius, seg, r, g, b, a)
    local cir = {}

    table.insert(cir, {x = x, y = y})
    for i = 0, seg do
        local arc = math.rad((i / seg) * -360)
        table.insert(cir, {x = x + math.sin( arc ) * radius, y = y + math.cos( arc ) * radius})
    end
    table.insert(cir, {x = x, y = y})

    surface.SetDrawColor(r, g, b, a)
    draw.NoTexture()
    surface.DrawPoly(cir)
end

function Star_Trek.LCARS:DrawFrameSpacePart(y, width, border, flip, color)
    -- Outer Circle
    Star_Trek.LCARS:DrawCircle(
        LCARS_CORNER_RADIUS,
        y + LCARS_CORNER_RADIUS,
        LCARS_CORNER_RADIUS - border, 16,
    color.r, color.g, color.b, color.a)

    -- Flat Piece
    if flip then
        draw.RoundedBox(0,
            border,
            y + LCARS_CORNER_RADIUS,
            (LCARS_CORNER_RADIUS - border) * 2, LCARS_CORNER_RADIUS,
        color)
    else
        draw.RoundedBox(0,
            border,
            y,
            (LCARS_CORNER_RADIUS - border) * 2, LCARS_CORNER_RADIUS,
        color)
    end

    -- Long Strip
    if flip then
        draw.RoundedBox(0,
            LCARS_CORNER_RADIUS - border,
            y + border,
            width - (LCARS_CORNER_RADIUS - border), LCARS_STRIP_HEIGHT - border * 2,
        color)
    else
        draw.RoundedBox(0,
            LCARS_CORNER_RADIUS - border,
            y + (LCARS_CORNER_RADIUS - border) * 2 - (LCARS_STRIP_HEIGHT - border) + border * 2,
            width - (LCARS_CORNER_RADIUS - border), LCARS_STRIP_HEIGHT - border * 2,
        color)
    end

    render.ClearStencil()
    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)
    render.SetStencilReferenceValue(255)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)

    -- Inner Circle
    render.SetStencilEnable(true)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
        if flip then
            Star_Trek.LCARS:DrawCircle(
                LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS,
                y + LCARS_STRIP_HEIGHT + LCARS_INNER_RADIUS,
                LCARS_INNER_RADIUS + border, 16,
            0, 0, 0, 1)
        else
            Star_Trek.LCARS:DrawCircle(
                LCARS_CORNER_RADIUS * 2 + LCARS_INNER_RADIUS,
                y + LCARS_CORNER_RADIUS * 2 - LCARS_STRIP_HEIGHT - LCARS_INNER_RADIUS,
                LCARS_INNER_RADIUS + border, 16,
            0, 0, 0, 1)
        end

        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
        if flip then
            draw.RoundedBox(0,
                LCARS_CORNER_RADIUS,
                y + LCARS_STRIP_HEIGHT - LCARS_BORDER_WIDTH,
                LCARS_CORNER_RADIUS + LCARS_INNER_RADIUS, LCARS_INNER_RADIUS + border,
            color)
        else
            draw.RoundedBox(0,
                LCARS_CORNER_RADIUS,
                y + LCARS_CORNER_RADIUS * 2 - LCARS_STRIP_HEIGHT - LCARS_INNER_RADIUS,
                LCARS_CORNER_RADIUS + LCARS_INNER_RADIUS, LCARS_INNER_RADIUS + border,
            color)
        end
    render.SetStencilEnable(false)
end

function Star_Trek.LCARS:DrawFrameSpacer(y, width, top_color, bottom_color)
    Star_Trek.LCARS:DrawFrameSpacePart(y, width, 0, false, Star_Trek.LCARS.ColorBlack)
    Star_Trek.LCARS:DrawFrameSpacePart(y, width, LCARS_BORDER_WIDTH, false, top_color)

    Star_Trek.LCARS:DrawFrameSpacePart(y + LCARS_CORNER_RADIUS * 2 + LCARS_FRAME_OFFSET, width, 0, true, Star_Trek.LCARS.ColorBlack)
    Star_Trek.LCARS:DrawFrameSpacePart(y + LCARS_CORNER_RADIUS * 2 + LCARS_FRAME_OFFSET, width, LCARS_BORDER_WIDTH, true, bottom_color)
end

function Star_Trek.LCARS:DrawFrame(width, height, title)
    Star_Trek.LCARS:DrawFrameSpacer(0, width, Star_Trek.LCARS.ColorOrange, Star_Trek.LCARS.ColorLightRed)
    draw.SimpleText(title, "LCARSMed", width - 4, 4, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

    local frameStartOffset = LCARS_CORNER_RADIUS * 4 + LCARS_FRAME_OFFSET
    local remainingHeight = height - frameStartOffset

    draw.RoundedBox(0,
        0,
        frameStartOffset,
        LCARS_CORNER_RADIUS * 2, remainingHeight,
    Star_Trek.LCARS.ColorBlack)

    draw.RoundedBox(0,
        LCARS_BORDER_WIDTH,
        frameStartOffset + LCARS_BORDER_WIDTH,
        LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
    Star_Trek.LCARS.ColorLightRed)

    draw.RoundedBox(0,
        LCARS_BORDER_WIDTH,
        frameStartOffset + LCARS_BORDER_WIDTH + remainingHeight / 2,
        LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
    Star_Trek.LCARS.ColorOrange)
end

function Star_Trek.LCARS:DrawDoubleFrame(width, height, title, height2)
    Star_Trek.LCARS:DrawFrameSpacer(0, width, Star_Trek.LCARS.ColorOrange, Star_Trek.LCARS.ColorLightRed)
    draw.SimpleText(title, "LCARSMed", width - 4, 4, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

    local topFrameStartOffset = LCARS_CORNER_RADIUS * 4 + LCARS_FRAME_OFFSET

    draw.RoundedBox(0,
        0,
        topFrameStartOffset,
        LCARS_CORNER_RADIUS * 2, height2 - topFrameStartOffset,
    Star_Trek.LCARS.ColorBlack)

    draw.RoundedBox(0,
        LCARS_BORDER_WIDTH,
        topFrameStartOffset + LCARS_BORDER_WIDTH,
        LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, height2 - topFrameStartOffset - LCARS_BORDER_WIDTH,
    Star_Trek.LCARS.ColorLightRed)

    Star_Trek.LCARS:DrawFrameSpacer(height2, width, Star_Trek.LCARS.ColorLightRed, Star_Trek.LCARS.ColorOrange)

    local bottomFrameStarOffset = height2 + topFrameStartOffset
    local remainingHeight = height - bottomFrameStarOffset

    draw.RoundedBox(0,
        0,
        bottomFrameStarOffset,
        LCARS_CORNER_RADIUS * 2, remainingHeight,
    Star_Trek.LCARS.ColorBlack)

    draw.RoundedBox(0,
        LCARS_BORDER_WIDTH,
        bottomFrameStarOffset + LCARS_BORDER_WIDTH,
        LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
    Star_Trek.LCARS.ColorOrange)

    draw.RoundedBox(0,
        LCARS_BORDER_WIDTH,
        bottomFrameStarOffset + LCARS_BORDER_WIDTH + remainingHeight / 2,
        LCARS_CORNER_RADIUS * 2 - LCARS_BORDER_WIDTH * 2, remainingHeight / 2 - LCARS_BORDER_WIDTH,
    Star_Trek.LCARS.ColorLightRed)
end

local function filterSize(value)
    return 2 ^ math.ceil(math.log(value) / math.log(2))
end

function Star_Trek.LCARS:CreateFrame(id, width, height, title, height2)
    tWidth = filterSize(width)
    tHeight = filterSize(height)

    local texture = GetRenderTarget("LCARS_Frame_" .. id, tWidth, tHeight)

    local oldW, oldH = ScrW(), ScrH()
    render.SetViewPort(0, 0, tWidth, tHeight)

    render.PushRenderTarget(texture)
    cam.Start2D()
        render.Clear(0, 0, 0, 0, true, true)

        if isnumber(height2) then
            Star_Trek.LCARS:DrawDoubleFrame(width, height, title, height2)
        else
            Star_Trek.LCARS:DrawFrame(width, height, title)
        end
    cam.End2D()
    render.PopRenderTarget()

    render.SetViewPort(0, 0, oldW, oldH)

    local material = CreateMaterial("LCARS_Frame_" .. id, "UnlitGeneric", {
        ["$basetexture"] = texture:GetName(),
        ["$translucent"] = 1,
        ["$vertexalpha"] = 1,
    })
    customMaterial = material

    local materialData = {
        Material = material,
        U = width / tWidth,
        V = height / tHeight,
    }

    PrintTable(materialData)

    return materialData
end

function Star_Trek.LCARS:RenderMaterial(x, y, w, h, materialData)
    surface.SetMaterial(materialData.Material)
    surface.DrawTexturedRectUV(x, y, w, h, 0, 0, materialData.U, materialData.V)
end
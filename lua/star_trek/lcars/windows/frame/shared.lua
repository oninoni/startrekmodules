---------------------------------------
---------------------------------------
--         Star Trek Modules         --
--                                   --
--            Created by             --
--       Jan 'Oninoni' Ziegler       --
--                                   --
-- This software can be used freely, --
--    but only distributed by me.    --
--                                   --
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--    LCARS Single Frame | Shared    --
---------------------------------------

if not istable(WINDOW) then Star_Trek:LoadAllModules() return end
local SELF = WINDOW

-- Enums
WINDOW_BORDER_LEFT = 0
WINDOW_BORDER_RIGHT = 1
WINDOW_BORDER_BOTH = 2

-- Determines the parent windows name for this one. (Like Deriving Classes)
SELF.BaseWindow = "base"
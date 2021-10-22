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
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--    LCARS Single Frame | Server    --
---------------------------------------

local SELF = WINDOW
function SELF:OnCreate(title, titleShort, hFlip)
	self.Height2 	= false
	self.Title 		= title or ""
	self.TitleShort = titleShort or self.Title
	self.HFlip 		= hFlip or false

	-- TODO: Modularize Colors
	self.Color1 = Star_Trek.LCARS.ColorOrange
	self.Color2 = Star_Trek.LCARS.ColorBlue
	self.Color3 = Star_Trek.LCARS.ColorLightRed
	self.Color4 = Star_Trek.LCARS.ColorBlue

	return true
end
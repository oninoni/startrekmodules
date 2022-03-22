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
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--        Utilities | Stardate       --
---------------------------------------

-- Time Offset Configuration
local START_YEAR_REAL = 2022
local START_YEAR_RP = 2380

-- Stardate Configuration.
local STARDATE_STANDARD_YEAR = 2323
local STARDATE_START_YEAR 	 = 0

local MONTHTABLE = {
	0,
	31,
	59,
	90,
	120,
	151,
	181,
	212,
	243,
	273,
	304,
	334,
}

function Star_Trek.Util:GetStardate(unixTime)
	local dateTable = os.date("*t", unixTime)

	-- Time Offset
	local y = dateTable.year + START_YEAR_RP - START_YEAR_REAL

	local n = 365 -- TODO: Detect Leap Year
	local monthOffset = MONTHTABLE[dateTable.month]

	return STARDATE_START_YEAR
	+ (1000 * (y - STARDATE_STANDARD_YEAR))
	+ ((1000 / n) * (
		monthOffset
		+ (dateTable.day - 1)
		+ (dateTable.hour / 24)
		+ (dateTable.min / (24 * 60)
		+ (dateTable.sec / (24 * 3600)))
	))
end